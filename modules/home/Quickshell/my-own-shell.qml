import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    id: root

    // ─── State ────────────────────────────────────────────────────────
    property int    cpuUsage:      0
    property int    ramUsage:      0
    property var    gpuList:       []

    // Volume via wpctl  (0–150, matches wpctl's 0.00–1.50 scale × 100)
    property int    volumePct:     50
    property bool   muted:         false

    // Brightness via brightnessctl
    property int    brightPct:     80

    // Network
    property bool   wifiUp:        false
    property bool   ethUp:         false
    property bool   btUp:          false
    property real   rxSpeed:       0       // bytes/s
    property real   txSpeed:       0       // bytes/s
    property real   _prevRx:       -1
    property real   _prevTx:       -1

    // Battery  (-1 = no battery present)
    property int    battPct:       -1
    property string battStatus:    ""      // Charging | Discharging | Full
    property string powerProfile:  ""      // performance | balanced | power-saver

    // Media (playerctl poll)
    property string playerStatus:  "Stopped"
    property string playerTitle:   ""
    property string playerArtist:  ""
    property real   playerPos:     0       // seconds
    property real   playerLen:     0       // seconds

    // Power menu
    property bool   powerMenuOpen: false
    property bool   menuClosing:   false

    // ─── Helpers ──────────────────────────────────────────────────────
    // Process API: use running = false → true, never .start()
    function runOnce(proc) {
        proc.running = false
        Qt.callLater(function() { proc.running = true })
    }

    function statColor(v, warn, crit) {
        return v >= crit ? "#ff6b6b" : v >= warn ? "#ffd93d" : Qt.rgba(1,1,1,0.90)
    }

    function fmtSpeed(bps) {
        if (bps >= 1048576) return (bps / 1048576).toFixed(1) + "M"
        if (bps >= 1024)    return Math.round(bps / 1024) + "K"
        return Math.round(bps) + "B"
    }

    // ─── Clock ────────────────────────────────────────────────────────
    SystemClock { id: clock; precision: SystemClock.Minutes }

    // ─── Process: CPU  (/proc/stat delta) ────────────────────────────
    Process {
        id: cpuProc; running: false
        command: ["cat", "/proc/stat"]
        property int pt: 0; property int pb: 0
        stdout: SplitParser {
            onRead: function(line) {
                if (!line.startsWith("cpu ")) return
                var f = line.trim().split(/\s+/)
                var idle = parseInt(f[4]) + parseInt(f[5])
                var tot  = 0; for (var i = 1; i <= 7; i++) tot += parseInt(f[i])
                var busy = tot - idle
                if (cpuProc.pt > 0) {
                    var dt = tot  - cpuProc.pt
                    var db = busy - cpuProc.pb
                    if (dt > 0) root.cpuUsage = Math.min(100, Math.max(0, Math.round(db/dt*100)))
                }
                cpuProc.pt = tot; cpuProc.pb = busy
            }
        }
    }

    // ─── Process: RAM  (/proc/meminfo) ───────────────────────────────
    Process {
        id: ramProc; running: false
        command: ["sh", "-c",
            "awk '/^MemTotal/{t=$2}/^MemAvailable/{a=$2}" +
            "END{printf \"%d\",int((t-a)/t*100)}' /proc/meminfo"]
        stdout: SplitParser {
            onRead: function(line) {
                var v = parseInt(line.trim()); if (!isNaN(v)) root.ramUsage = v
            }
        }
    }

    // ─── Process: GPU  (AMD/Intel sysfs + optional nvidia-smi) ───────
    // Only GPUs that actually exist are shown. iGPU, AMD dGPU, NVIDIA.
    Process {
        id: gpuProc; running: false
        command: ["sh", "-c",
            "for card in /sys/class/drm/card[0-9]*/; do " +
            "  b=\"${card}device/gpu_busy_percent\"; " +
            "  [ -f \"$b\" ] || continue; " +
            "  p=$(cat \"$b\" 2>/dev/null || echo 0); " +
            "  v=$(cat \"${card}device/vendor\" 2>/dev/null || echo x); " +
            "  case $v in 0x8086) n=iGPU;; 0x1002) n=AMD;; 0x10de) n=NV;; *) n=GPU;; esac; " +
            "  echo \"$n $p\"; " +
            "done; " +
            "command -v nvidia-smi >/dev/null 2>&1 && " +
            "nvidia-smi --query-gpu=name,utilization.gpu --format=csv,noheader,nounits 2>/dev/null | " +
            "awk -F',' '{gsub(/ /,\"\",$1); printf \"%s %s\\n\",$1,$2}' || true"]
        property var tmp: []
        onRunningChanged: {
            if (running) { tmp = [] } else { if (tmp.length > 0) root.gpuList = tmp }
        }
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.trim().split(" ")
                if (p.length >= 2) {
                    var lst = gpuProc.tmp.slice()
                    lst.push({ name: p[0], usage: parseInt(p[1]) || 0 })
                    gpuProc.tmp = lst
                }
            }
        }
    }

    // ─── Process: Volume  (wpctl – matches your binds.conf) ──────────
    Process {
        id: volQuery; running: false
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo 'Volume: 0.50'"]
        stdout: SplitParser {
            onRead: function(line) {
                // "Volume: 0.72"  or  "Volume: 0.72 [MUTED]"
                var m = line.match(/Volume:\s*([\d.]+)/)
                if (m) root.volumePct = Math.min(150, Math.round(parseFloat(m[1]) * 100))
                root.muted = line.includes("[MUTED]")
            }
        }
    }

    // ─── Process: Brightness  (brightnessctl – matches your binds.conf)
    Process {
        id: brightQuery; running: false
        command: ["sh", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo 80"]
        stdout: SplitParser {
            onRead: function(line) {
                var v = parseInt(line.trim()); if (!isNaN(v)) root.brightPct = Math.max(1, v)
            }
        }
    }

    // ─── Process: Network  (sysfs, speed delta every 2 s) ────────────
    Process {
        id: netProc; running: false
        command: ["sh", "-c",
            "rx=0; tx=0; wifi=0; eth=0; " +
            "for d in /sys/class/net/*/; do " +
            "  n=$(basename $d); [ \"$n\" = lo ] && continue; " +
            "  st=$(cat \"$d/operstate\" 2>/dev/null || echo down); " +
            "  [ \"$st\" = up ] || continue; " +
            "  case $n in wl*) wifi=1;; e*|en*) eth=1;; esac; " +
            "  rx=$((rx + $(cat \"$d/statistics/rx_bytes\" 2>/dev/null || echo 0))); " +
            "  tx=$((tx + $(cat \"$d/statistics/tx_bytes\" 2>/dev/null || echo 0))); " +
            "done; " +
            "bt=$(rfkill list bluetooth 2>/dev/null | grep -c 'Soft blocked: no' || echo 0); " +
            "echo \"$wifi $eth $bt $rx $tx\""]
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.trim().split(" ")
                if (p.length < 5) return
                root.wifiUp = (p[0] === "1")
                root.ethUp  = (p[1] === "1")
                root.btUp   = (parseInt(p[2]) > 0)
                var rx = parseFloat(p[3]); var tx = parseFloat(p[4])
                if (root._prevRx >= 0) {
                    root.rxSpeed = Math.max(0, (rx - root._prevRx) / 2)
                    root.txSpeed = Math.max(0, (tx - root._prevTx) / 2)
                }
                root._prevRx = rx; root._prevTx = tx
            }
        }
    }

    // ─── Process: Battery + Power Profile ────────────────────────────
    Process {
        id: battProc; running: false
        command: ["sh", "-c",
            "bat=$(ls /sys/class/power_supply/BAT* 2>/dev/null | head -1); " +
            "if [ -n \"$bat\" ]; then " +
            "  echo \"BAT $(cat $bat/capacity 2>/dev/null || echo 0) $(cat $bat/status 2>/dev/null || echo Unknown)\"; " +
            "else echo \"BAT none\"; fi; " +
            "prof=$(powerprofilesctl get 2>/dev/null || " +
            "  cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo balanced); " +
            "echo \"PROF $prof\""]
        stdout: SplitParser {
            onRead: function(line) {
                if (line.startsWith("BAT ")) {
                    var p = line.slice(4).trim().split(" ")
                    if (p[0] === "none") { root.battPct = -1 }
                    else { root.battPct = parseInt(p[0]) || 0; root.battStatus = p[1] || "" }
                } else if (line.startsWith("PROF ")) {
                    root.powerProfile = line.slice(5).trim()
                }
            }
        }
    }

    // ─── Process: Playerctl (1 s poll, replaces unreliable Mpris service)
    Process {
        id: playerProc; running: false
        command: ["sh", "-c",
            "playerctl metadata " +
            "--format '{{status}}|{{title}}|{{artist}}|{{position}}|{{mpris:length}}' " +
            "2>/dev/null || echo 'Stopped|||0|0'"]
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.split("|")
                root.playerStatus = (p[0] || "Stopped").trim()
                root.playerTitle  = (p[1] || "").trim()
                root.playerArtist = (p[2] || "").trim()
                // playerctl format outputs microseconds for position & length
                root.playerPos    = (parseFloat(p[3]) || 0) / 1000000
                root.playerLen    = (parseFloat(p[4]) || 0) / 1000000
            }
        }
    }

    // ─── Master poll timers ───────────────────────────────────────────
    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running)     cpuProc.running     = true
            if (!ramProc.running)     ramProc.running     = true
            if (!gpuProc.running)     gpuProc.running     = true
            if (!volQuery.running)    volQuery.running    = true
            if (!brightQuery.running) brightQuery.running = true
            if (!netProc.running)     netProc.running     = true
            if (!battProc.running)    battProc.running    = true
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { if (!playerProc.running) playerProc.running = true }
    }

    // ─── Action processes ─────────────────────────────────────────────
    // wpctl matches your binds.conf exactly
    Process { id: muteProc;        running: false; command: ["wpctl","set-mute","@DEFAULT_AUDIO_SINK@","toggle"] }
    Process { id: lockProc;        running: false; command: ["loginctl","lock-session"] }
    Process { id: logoutProc;      running: false; command: ["hyprctl","dispatch","exit"] }
    Process { id: hibernateProc;   running: false; command: ["systemctl","hibernate"] }
    Process { id: rebootProc;      running: false; command: ["systemctl","reboot"] }
    Process { id: shutdownProc;    running: false; command: ["systemctl","poweroff"] }
    Process { id: playerPlayPause; running: false; command: ["playerctl","play-pause"] }
    Process { id: playerNext;      running: false; command: ["playerctl","next"] }
    Process { id: playerPrev;      running: false; command: ["playerctl","previous"] }
    Process {
        id: volSetProc; running: false
        property string val: "0.50"
        // wpctl takes float 0.0–1.5, matching your "wpctl set-volume -l 1.5" binds
        command: ["wpctl","set-volume","-l","1.5","@DEFAULT_AUDIO_SINK@",val]
    }
    Process {
        id: brightSetProc; running: false
        property string val: "80%"
        command: ["brightnessctl","s",val]
    }

    // ═════════════════════════════════════════════════════════════════
    //  MAIN BAR
    // ═════════════════════════════════════════════════════════════════
    PanelWindow {
        id: bar
        anchors.top: true; anchors.left: true; anchors.right: true
        implicitHeight: 54
        color: "transparent"
        exclusiveZone: implicitHeight

        // Full-width pill spanning screen edge to edge (12 px margins)
        Rectangle {
            id: pill
            anchors { top: parent.top; topMargin: 8; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
            height: 38; radius: 10
            color: "#dd111827"
            border.color: Qt.rgba(1,1,1,0.09); border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14; anchors.rightMargin: 14
                spacing: 10

                // ── Workspace dots (GNOME pill style) ─────────────────
                // Active → wide purple pill; has windows → bright dot; empty → dim dot
                RowLayout {
                    spacing: 5; Layout.alignment: Qt.AlignVCenter
                    Repeater {
                        // Hyprland.workspaces is the reactive model – use it directly
                        model: Hyprland.workspaces
                        delegate: Item {
                            id: wsDot
                            required property var modelData
                            visible: modelData.id > 0
                            Layout.alignment: Qt.AlignVCenter
                            implicitHeight: 7
                            implicitWidth:  isFocused ? 20 : 7

                            property bool isFocused: {
                                var fw = Hyprland.focusedWorkspace
                                return fw !== null && fw !== undefined && fw.id === modelData.id
                            }
                            property bool hasWin: (modelData.windows !== undefined && modelData.windows > 0)

                            Behavior on implicitWidth {
                                SpringAnimation { spring: 6.0; damping: 0.58; mass: 0.5; epsilon: 0.25 }
                            }

                            Rectangle {
                                width:  wsDot.implicitWidth; height: 7
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3.5
                                color: wsDot.isFocused  ? "#c792ea"
                                     : wsDot.hasWin     ? Qt.rgba(1,1,1,0.60)
                                     :                    Qt.rgba(1,1,1,0.20)
                                Behavior on color { ColorAnimation { duration: 180 } }
                                Behavior on width { SpringAnimation { spring: 6.0; damping: 0.58; mass: 0.5 } }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + wsDot.modelData.id)
                            }
                        }
                    }
                }

                // ── App title + class (package name) ──────────────────
                // title is normal weight; class is the WM_CLASS (app/package name), smaller+muted
                // NOTE: "class" is a JS reserved word – use bracket notation focusedWindow["class"]
                Column {
                    spacing: 0; Layout.alignment: Qt.AlignVCenter
                    visible: {
                        var w = Hyprland.focusedWindow
                        return w !== null && w !== undefined && (w.title || "") !== ""
                    }
                    Text {
                        text: {
                            var w = Hyprland.focusedWindow
                            return (w && w.title) ? w.title : ""
                        }
                        color: Qt.rgba(1,1,1,0.88)
                        font.pixelSize: 12; font.weight: Font.Medium
                        width: Math.min(implicitWidth, 200); elide: Text.ElideRight
                    }
                    Text {
                        text: {
                            var w = Hyprland.focusedWindow
                            return (w && w["class"]) ? w["class"] : ""
                        }
                        color: Qt.rgba(1,1,1,0.38)
                        font.pixelSize: 9; font.weight: Font.Normal
                        width: Math.min(implicitWidth, 200); elide: Text.ElideRight
                    }
                }

                Item { Layout.fillWidth: true }

                // ── MPRIS (playerctl) ──────────────────────────────────
                // Styled like the stat columns: artist = small muted label, title = bold value
                // Only shown when something is Playing or Paused
                RowLayout {
                    spacing: 6
                    visible: root.playerStatus === "Playing" || root.playerStatus === "Paused"
                    Layout.alignment: Qt.AlignVCenter

                    // Controls – same style as playerctl binds
                    Text { text: "⏮"; font.pixelSize: 11; color: Qt.rgba(1,1,1,0.50); Layout.alignment: Qt.AlignVCenter
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked: root.runOnce(playerPrev) } }
                    Text {
                        text: root.playerStatus === "Playing" ? "⏸" : "▶"
                        font.pixelSize: 14; color: Qt.rgba(1,1,1,0.95); Layout.alignment: Qt.AlignVCenter
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked: root.runOnce(playerPlayPause) } }
                    Text { text: "⏭"; font.pixelSize: 11; color: Qt.rgba(1,1,1,0.50); Layout.alignment: Qt.AlignVCenter
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked: root.runOnce(playerNext) } }

                    // Track info – matches CPU/RAM column format
                    Column {
                        spacing: 2; Layout.alignment: Qt.AlignVCenter; Layout.maximumWidth: 150

                        // Artist as the small muted label (like "CPU")
                        Text {
                            width: parent.width
                            text: root.playerArtist !== "" ? root.playerArtist : "MEDIA"
                            color: Qt.rgba(1,1,1,0.40); font.pixelSize: 8; font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                        // Title as the bold value (like "28%")
                        Text {
                            width: parent.width
                            text: root.playerTitle !== "" ? root.playerTitle : "Unknown"
                            color: Qt.rgba(1,1,1,0.92); font.pixelSize: 12; font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        // Progress bar below title
                        Rectangle {
                            width: parent.width; height: 2; radius: 1; color: Qt.rgba(1,1,1,0.12)
                            Rectangle {
                                height: 2; radius: 1; color: "#c792ea"
                                width: root.playerLen > 0
                                    ? Math.min(1.0, root.playerPos / root.playerLen) * parent.width : 0
                                Behavior on width { SmoothedAnimation { velocity: 18 } }
                            }
                        }
                    }

                    Rectangle { width:1; height:20; radius:1; color:Qt.rgba(1,1,1,0.12) }
                }

                // ── System Tray ────────────────────────────────────────
                Repeater {
                    model: SystemTray.items
                    delegate: Item {
                        id: trayItem
                        required property SystemTrayItem modelData
                        implicitWidth: 18; implicitHeight: 18
                        Layout.alignment: Qt.AlignVCenter
                        Image {
                            anchors.centerIn: parent; width: 16; height: 16
                            source: trayItem.modelData.icon
                            fillMode: Image.PreserveAspectFit; smooth: true
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: trayItem.modelData.activate(0, 0)
                        }
                    }
                }

                // ── Network: icons + ↓↑ speeds ────────────────────────
                // WiFi  Ethernet  Bluetooth  |  ↓ speed / ↑ speed
                // Only visible if at least one interface is active
                RowLayout {
                    spacing: 4; Layout.alignment: Qt.AlignVCenter
                    visible: root.wifiUp || root.ethUp || root.btUp

                    // Icon row (nerd font chars, widely available on Hyprland setups)
                    // If icons show as boxes, install a Nerd Font (JetBrainsMono Nerd Font etc.)
                    Text { text:"\uf1eb"; visible:root.wifiUp; color:"#82aaff"; font.pixelSize:12;  // 
                        font.family: "monospace" }
                    Text { text:"\uf796"; visible:root.ethUp;  color:"#89ddff"; font.pixelSize:12;  // 
                        font.family: "monospace" }
                    Text { text:"\uf294"; visible:root.btUp;   color:"#c792ea"; font.pixelSize:12;  // 
                        font.family: "monospace" }

                    // Speed column styled like CPU/RAM (label above, value below)
                    Column {
                        spacing: 0; Layout.alignment: Qt.AlignVCenter
                        visible: root.wifiUp || root.ethUp
                        Text {
                            text: "↓ " + root.fmtSpeed(root.rxSpeed) + "/s"
                            color: Qt.rgba(1,1,1,0.75); font.pixelSize: 9; font.weight: Font.Medium
                        }
                        Text {
                            text: "↑ " + root.fmtSpeed(root.txSpeed) + "/s"
                            color: Qt.rgba(1,1,1,0.55); font.pixelSize: 9; font.weight: Font.Medium
                        }
                    }
                }

                // ── Battery (hidden if no battery) ────────────────────
                RowLayout {
                    spacing: 6; Layout.alignment: Qt.AlignVCenter
                    visible: root.battPct >= 0

                    // Battery percentage + charging icon
                    Column {
                        spacing: 0; Layout.alignment: Qt.AlignVCenter
                        Text { anchors.horizontalCenter:parent.horizontalCenter; text:"BAT"
                            color:Qt.rgba(1,1,1,0.40); font.pixelSize:8; font.weight:Font.Medium }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter; spacing: 2
                            Text {
                                text: root.battPct + "%"
                                font.pixelSize: 12; font.weight: Font.DemiBold
                                color: root.battPct <= 15 ? "#ff6b6b"
                                     : root.battPct <= 35 ? "#ffd93d"
                                     :                      Qt.rgba(1,1,1,0.90)
                                Behavior on color { ColorAnimation { duration: 500 } }
                            }
                            Text {
                                text: root.battStatus === "Charging" ? "⚡"
                                    : root.battStatus === "Full"     ? "✓"
                                    :                                   ""
                                font.pixelSize: 10; color: "#ffd93d"
                                topPadding: 1
                            }
                        }
                    }

                    // Power profile column (Performance / Balanced / Save)
                    Column {
                        spacing: 0; Layout.alignment: Qt.AlignVCenter
                        visible: root.powerProfile !== ""
                        Text { anchors.horizontalCenter:parent.horizontalCenter; text:"PWR"
                            color:Qt.rgba(1,1,1,0.40); font.pixelSize:8; font.weight:Font.Medium }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: {
                                var p = root.powerProfile.toLowerCase()
                                if (p.indexOf("perf") >= 0)               return "Perf"
                                if (p.indexOf("power-sav") >= 0
                                 || p.indexOf("power_sav") >= 0
                                 || p.indexOf("low-power") >= 0)           return "Save"
                                return "Bal"
                            }
                            font.pixelSize: 12; font.weight: Font.DemiBold
                            color: {
                                var p = root.powerProfile.toLowerCase()
                                if (p.indexOf("perf") >= 0)               return "#ff6b6b"
                                if (p.indexOf("power-sav") >= 0
                                 || p.indexOf("power_sav") >= 0
                                 || p.indexOf("low-power") >= 0)           return "#82aaff"
                                return Qt.rgba(1,1,1,0.90)
                            }
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                    }
                }

                // ── GPU  (only rendered when GPUs are detected) ────────
                Repeater {
                    model: root.gpuList
                    delegate: Column {
                        id: gpuCol; required property var modelData
                        spacing: 0; Layout.alignment: Qt.AlignVCenter
                        Text { anchors.horizontalCenter:parent.horizontalCenter
                            text:gpuCol.modelData.name; color:Qt.rgba(1,1,1,0.40)
                            font.pixelSize:8; font.weight:Font.Medium }
                        Text { anchors.horizontalCenter:parent.horizontalCenter
                            text:(gpuCol.modelData.usage||0)+"%"
                            font.pixelSize:12; font.weight:Font.DemiBold
                            color:root.statColor(gpuCol.modelData.usage||0, 50, 80)
                            Behavior on color { ColorAnimation { duration:500 } } }
                    }
                }

                // ── CPU ────────────────────────────────────────────────
                Column {
                    spacing: 0; Layout.alignment: Qt.AlignVCenter
                    Text { anchors.horizontalCenter:parent.horizontalCenter; text:"CPU"
                        color:Qt.rgba(1,1,1,0.40); font.pixelSize:8; font.weight:Font.Medium }
                    Text { anchors.horizontalCenter:parent.horizontalCenter
                        text:root.cpuUsage+"%"; font.pixelSize:12; font.weight:Font.DemiBold
                        color:root.statColor(root.cpuUsage, 50, 80)
                        Behavior on color { ColorAnimation { duration:500 } } }
                }

                // ── RAM ────────────────────────────────────────────────
                Column {
                    spacing: 0; Layout.alignment: Qt.AlignVCenter
                    Text { anchors.horizontalCenter:parent.horizontalCenter; text:"RAM"
                        color:Qt.rgba(1,1,1,0.40); font.pixelSize:8; font.weight:Font.Medium }
                    Text { anchors.horizontalCenter:parent.horizontalCenter
                        text:root.ramUsage+"%"; font.pixelSize:12; font.weight:Font.DemiBold
                        color:root.statColor(root.ramUsage, 60, 80)
                        Behavior on color { ColorAnimation { duration:500 } } }
                }

                Rectangle { width:1; height:20; radius:1; color:Qt.rgba(1,1,1,0.12); Layout.alignment:Qt.AlignVCenter }

                // ── Brightness icon + spring slider ────────────────────
                Text { text:"☀"; font.pixelSize:13; color:Qt.rgba(1,1,1,0.60); Layout.alignment:Qt.AlignVCenter }
                Slider {
                    id: brightSlider; from:1; to:100; padding:0
                    implicitWidth:60; implicitHeight:20; Layout.alignment:Qt.AlignVCenter
                    Binding { target:brightSlider; property:"value"; value:root.brightPct; when:!brightSlider.pressed }
                    onMoved: { brightSetProc.val = Math.round(value)+"%"; root.runOnce(brightSetProc) }
                    background: Rectangle {
                        x:brightSlider.leftPadding; y:brightSlider.topPadding+(brightSlider.availableHeight-height)/2
                        width:brightSlider.availableWidth; height:4; radius:2; color:Qt.rgba(1,1,1,0.12)
                        Rectangle { width:brightSlider.visualPosition*parent.width; height:4; radius:2; color:"#ffd93d"
                            Behavior on width { SpringAnimation { spring:6; damping:0.75; epsilon:0.5 } } }
                    }
                    handle: Rectangle {
                        x:brightSlider.leftPadding+brightSlider.visualPosition*(brightSlider.availableWidth-width)
                        y:brightSlider.topPadding+(brightSlider.availableHeight-height)/2
                        width:14; height:14; radius:7; color:"white"
                        Behavior on x { SpringAnimation { spring:6; damping:0.75; epsilon:0.5 } }
                    }
                }

                // ── Volume icon + spring slider ────────────────────────
                // wpctl volume 0.0–1.5 mapped to slider 0–150
                Text {
                    text: root.muted||root.volumePct===0 ? "🔇" : root.volumePct>80 ? "🔊" : root.volumePct>40 ? "🔉" : "🔈"
                    font.pixelSize:14; Layout.alignment:Qt.AlignVCenter
                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                        onClicked: { root.muted = !root.muted; root.runOnce(muteProc) } }
                }
                Slider {
                    id: volSlider; from:0; to:150; padding:0
                    implicitWidth:60; implicitHeight:20; Layout.alignment:Qt.AlignVCenter
                    Binding { target:volSlider; property:"value"; value:root.volumePct; when:!volSlider.pressed }
                    onMoved: {
                        volSetProc.val = (Math.round(value)/100).toFixed(2)
                        root.runOnce(volSetProc)
                    }
                    background: Rectangle {
                        x:volSlider.leftPadding; y:volSlider.topPadding+(volSlider.availableHeight-height)/2
                        width:volSlider.availableWidth; height:4; radius:2; color:Qt.rgba(1,1,1,0.12)
                        Rectangle {
                            width: (volSlider.value/150)*parent.width; height:4; radius:2
                            color:root.muted?"#ff6b6b":"#c792ea"
                            Behavior on width { SpringAnimation { spring:6; damping:0.75; epsilon:0.5 } }
                            Behavior on color { ColorAnimation { duration:200 } }
                        }
                    }
                    handle: Rectangle {
                        x:volSlider.leftPadding+volSlider.visualPosition*(volSlider.availableWidth-width)
                        y:volSlider.topPadding+(volSlider.availableHeight-height)/2
                        width:14; height:14; radius:7
                        color:root.muted?"#ff6b6b":"white"
                        Behavior on x     { SpringAnimation { spring:6; damping:0.75; epsilon:0.5 } }
                        Behavior on color { ColorAnimation { duration:200 } }
                    }
                }

                Rectangle { width:1; height:20; radius:1; color:Qt.rgba(1,1,1,0.12); Layout.alignment:Qt.AlignVCenter }

                // ── Clock (12-hour) + date ─────────────────────────────
                Column {
                    spacing: 1; Layout.alignment: Qt.AlignVCenter
                    Text { anchors.horizontalCenter:parent.horizontalCenter
                        text:Qt.formatTime(clock.date,"h:mm AP")
                        color:Qt.rgba(1,1,1,0.95); font.pixelSize:13; font.weight:Font.DemiBold }
                    Text { anchors.horizontalCenter:parent.horizontalCenter
                        text:Qt.formatDate(clock.date,"ddd, MMM d")
                        color:Qt.rgba(1,1,1,0.45); font.pixelSize:9 }
                }

                // ── Power button ───────────────────────────────────────
                Rectangle {
                    id: powerBtn; Layout.alignment:Qt.AlignVCenter
                    width:26; height:26; radius:13
                    color:powerMa.containsMouse?Qt.rgba(1,0.15,0.15,0.42):Qt.rgba(1,1,1,0.08)
                    Behavior on color { ColorAnimation { duration:150 } }
                    scale:1.0; Behavior on scale { SpringAnimation { spring:10; damping:0.40; mass:0.5 } }
                    Text { anchors.centerIn:parent; text:"⏻"; font.pixelSize:13
                        color:powerMa.containsMouse?"#ff6b6b":Qt.rgba(1,1,1,0.65)
                        Behavior on color { ColorAnimation { duration:150 } } }
                    Timer { id:bounceT; interval:90; onTriggered: powerBtn.scale = 1.0 }
                    MouseArea { id:powerMa; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                        onClicked: { powerBtn.scale=0.78; bounceT.restart(); root.powerMenuOpen = !root.powerMenuOpen } }
                }

            } // RowLayout
        } // pill
    } // bar PanelWindow

    // ═════════════════════════════════════════════════════════════════
    //  POWER MENU POPUP
    //  Slides down from behind bar on open (OutBack overshoot),
    //  slides back up on close (InCubic). menuClosing keeps it alive
    //  through the close animation.
    // ═════════════════════════════════════════════════════════════════
    PanelWindow {
        id: powerPopup
        visible:       root.powerMenuOpen || root.menuClosing
        anchors.top:   true
        anchors.right: true
        implicitWidth:  192
        implicitHeight: 320
        color:          "transparent"
        exclusiveZone:  0

        readonly property real closedY: 2.0   // tucked behind bar
        readonly property real openY:   58.0  // just below bar (54 px bar + 4 gap)

        Rectangle {
            id: menuBox
            width:168; radius:10
            anchors.right:parent.right; anchors.rightMargin:12
            height: menuCol.implicitHeight + 20
            color:"#f0111827"; border.color:Qt.rgba(1,1,1,0.10); border.width:1
            clip:true; y:powerPopup.closedY; opacity:0.0

            NumberAnimation { id:openSlide;  target:menuBox; property:"y";
                from:powerPopup.closedY; to:powerPopup.openY;
                duration:420; easing.type:Easing.OutBack; easing.overshoot:1.3 }
            NumberAnimation { id:openFade;   target:menuBox; property:"opacity";
                from:0.0; to:1.0; duration:220 }
            NumberAnimation { id:closeSlide; target:menuBox; property:"y";
                from:powerPopup.openY; to:powerPopup.closedY;
                duration:250; easing.type:Easing.InCubic;
                onFinished: root.menuClosing = false }
            NumberAnimation { id:closeFade;  target:menuBox; property:"opacity";
                from:1.0; to:0.0; duration:200 }

            Column {
                id: menuCol
                anchors { top:parent.top; topMargin:10; left:parent.left; leftMargin:10; right:parent.right; rightMargin:10 }
                spacing: 4

                Repeater {
                    model: [
                        { label:"Lock",      emoji:"🔒", key:"lock"      },
                        { label:"Logout",    emoji:"🚪", key:"logout"    },
                        { label:"Hibernate", emoji:"💤", key:"hibernate" },
                        { label:"Reboot",    emoji:"🔁", key:"reboot"   },
                        { label:"Shutdown",  emoji:"⏻",  key:"shutdown"  },
                    ]
                    delegate: Rectangle {
                        id: mRow; required property var modelData
                        width:parent.width; height:36; radius:7
                        color:rHov.containsMouse?Qt.rgba(1,1,1,0.12):"transparent"
                        Behavior on color { ColorAnimation { duration:120 } }
                        scale:rHov.containsMouse?1.03:1.0
                        Behavior on scale { SpringAnimation { spring:8; damping:0.58 } }
                        RowLayout {
                            anchors.fill:parent; anchors.leftMargin:10; anchors.rightMargin:10; spacing:8
                            Text { text:mRow.modelData.emoji; font.pixelSize:16 }
                            Text { text:mRow.modelData.label; color:Qt.rgba(1,1,1,0.90); font.pixelSize:13; Layout.fillWidth:true }
                        }
                        MouseArea {
                            id:rHov; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                            onClicked: {
                                root.powerMenuOpen = false
                                var k = mRow.modelData.key
                                if      (k==="lock")      root.runOnce(lockProc)
                                else if (k==="logout")    root.runOnce(logoutProc)
                                else if (k==="hibernate") root.runOnce(hibernateProc)
                                else if (k==="reboot")    root.runOnce(rebootProc)
                                else if (k==="shutdown")  root.runOnce(shutdownProc)
                            }
                        }
                    }
                }
            }
        } // menuBox

        Connections {
            target: root
            function onPowerMenuOpenChanged() {
                if (root.powerMenuOpen) {
                    menuBox.y = powerPopup.closedY; menuBox.opacity = 0.0
                    openSlide.start(); openFade.start()
                } else {
                    root.menuClosing = true
                    closeSlide.start(); closeFade.start()
                }
            }
        }
    } // powerPopup PanelWindow

} // ShellRoot
