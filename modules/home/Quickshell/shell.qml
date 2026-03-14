import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    id: root

    // ── State ─────────────────────────────────────────────────
    property int  cpuUsage:      0
    property int  ramUsage:      0
    property var  gpuList:       []
    property int  volumePct:     50
    property bool muted:         false
    property int  brightPct:     80
    property bool powerMenuOpen: false
    property bool menuClosing:   false

    property var mprisPlayer: (Mpris.players.length > 0) ? Mpris.players[0] : null

    // KEY FIX: Process has no .start() — use running = true via Qt.callLater
    function runOnce(proc) {
        proc.running = false
        Qt.callLater(function() { proc.running = true })
    }

    // ── Clock ─────────────────────────────────────────────────
    SystemClock { id: clock; precision: SystemClock.Minutes }

    // Tick so MPRIS progress bar updates every second
    Timer { interval: 1000; running: root.mprisPlayer !== null; repeat: true }

    // ── CPU – /proc/stat delta ────────────────────────────────
    Process {
        id: cpuProc
        running: false
        command: ["cat", "/proc/stat"]
        property int pt: 0
        property int pb: 0
        stdout: SplitParser {
            onRead: function(line) {
                if (!line.startsWith("cpu ")) return
                var f = line.trim().split(/\s+/)
                var idle  = parseInt(f[4]) + parseInt(f[5])
                var total = 0
                for (var i = 1; i <= 7; i++) total += parseInt(f[i])
                var busy = total - idle
                if (cpuProc.pt > 0) {
                    var dt = total - cpuProc.pt
                    var db = busy  - cpuProc.pb
                    if (dt > 0)
                        root.cpuUsage = Math.min(100, Math.max(0, Math.round(db / dt * 100)))
                }
                cpuProc.pt = total
                cpuProc.pb = busy
            }
        }
    }

    // ── RAM – /proc/meminfo ───────────────────────────────────
    Process {
        id: ramProc
        running: false
        command: ["sh", "-c",
            "awk '/^MemTotal/{t=$2}/^MemAvailable/{a=$2}" +
            "END{printf \"%d\",int((t-a)/t*100)}' /proc/meminfo"]
        stdout: SplitParser {
            onRead: function(line) {
                var v = parseInt(line.trim())
                if (!isNaN(v)) root.ramUsage = v
            }
        }
    }

    // ── GPU – AMD sysfs + optional nvidia-smi ─────────────────
    // Shows only GPUs that actually exist on the machine.
    // iGPU (Intel=0x8086, AMD=0x1002), dGPU/eGPU (NVIDIA=0x10de) auto-detected.
    Process {
        id: gpuProc
        running: false
        command: ["sh", "-c",
            "for card in /sys/class/drm/card*/; do " +
            "  b=\"${card}device/gpu_busy_percent\"; " +
            "  [ -f \"$b\" ] || continue; " +
            "  p=$(cat \"$b\" 2>/dev/null || echo 0); " +
            "  v=$(cat \"${card}device/vendor\" 2>/dev/null || echo x); " +
            "  case \"$v\" in " +
            "    0x8086) n=iGPU;; " +
            "    0x1002) n=AMD;; " +
            "    0x10de) n=NVIDIA;; " +
            "    *) n=GPU;; " +
            "  esac; " +
            "  echo \"$n $p\"; " +
            "done; " +
            "command -v nvidia-smi >/dev/null 2>&1 && " +
            "nvidia-smi --query-gpu=name,utilization.gpu " +
            "--format=csv,noheader,nounits 2>/dev/null | " +
            "awk -F',' '{gsub(/ /,\"\",$1); printf \"%s %s\\n\",$1,$2}' || true"]
        property var tmp: []
        onRunningChanged: {
            if (running) {
                tmp = []
            } else {
                if (tmp.length > 0) root.gpuList = tmp
            }
        }
        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.trim().split(" ")
                if (parts.length >= 2) {
                    var lst = gpuProc.tmp.slice()
                    lst.push({ name: parts[0], usage: parseInt(parts[1]) || 0 })
                    gpuProc.tmp = lst
                }
            }
        }
    }

    // ── Volume – pactl ────────────────────────────────────────
    Process {
        id: volQuery
        running: false
        command: ["sh", "-c",
            "V=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null " +
            "  | grep -oP '\\d+(?=%)' | head -1 || echo 50); " +
            "M=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null " +
            "  | awk '{print $2}' || echo no); " +
            "echo \"$V $M\""]
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.trim().split(" ")
                if (p.length >= 1) {
                    var v = parseInt(p[0])
                    if (!isNaN(v)) root.volumePct = Math.min(150, Math.max(0, v))
                }
                if (p.length >= 2) root.muted = (p[1] === "yes")
            }
        }
    }

    // ── Brightness – brightnessctl ────────────────────────────
    Process {
        id: brightQuery
        running: false
        command: ["sh", "-c",
            "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo 80"]
        stdout: SplitParser {
            onRead: function(line) {
                var v = parseInt(line.trim())
                if (!isNaN(v)) root.brightPct = Math.max(1, v)
            }
        }
    }

    // ── Master poll timer ─────────────────────────────────────
    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running)     cpuProc.running     = true
            if (!ramProc.running)     ramProc.running     = true
            if (!gpuProc.running)     gpuProc.running     = true
            if (!volQuery.running)    volQuery.running    = true
            if (!brightQuery.running) brightQuery.running = true
        }
    }

    // ── One-shot action processes ─────────────────────────────
    Process { id: muteProc;      running: false; command: ["pactl","set-sink-mute","@DEFAULT_SINK@","toggle"] }
    Process { id: lockProc;      running: false; command: ["loginctl","lock-session"] }
    Process { id: logoutProc;    running: false; command: ["hyprctl","dispatch","exit"] }
    Process { id: hibernateProc; running: false; command: ["systemctl","hibernate"] }
    Process { id: rebootProc;    running: false; command: ["systemctl","reboot"] }
    Process { id: shutdownProc;  running: false; command: ["systemctl","poweroff"] }

    Process {
        id: volSetProc; running: false
        property string pct: "50%"
        command: ["pactl","set-sink-volume","@DEFAULT_SINK@",pct]
    }
    Process {
        id: brightSetProc; running: false
        property string val: "50%"
        command: ["brightnessctl","s",val]
    }

    // ─────────────────────────────────────────────────────────
    //  MAIN BAR
    // ─────────────────────────────────────────────────────────
    PanelWindow {
        id: bar
        anchors.top: true; anchors.left: true; anchors.right: true
        implicitHeight: 54
        color: "transparent"
        exclusiveZone: implicitHeight

        Rectangle {
            id: pill
            anchors {
                top:  parent.top;  topMargin:   8
                left: parent.left; leftMargin:  12
                right: parent.right; rightMargin: 12
            }
            height: 38; radius: 10
            color:        "#dd111827"
            border.color: Qt.rgba(1,1,1,0.09); border.width: 1

            RowLayout {
                anchors.fill:        parent
                anchors.leftMargin:  12
                anchors.rightMargin: 12
                spacing: 8

                // ── Workspaces – GNOME pill dots, no numbers ───
                RowLayout {
                    spacing: 5
                    Layout.alignment: Qt.AlignVCenter

                    Repeater {
                        model: {
                            var ws = []
                            for (var i = 0; i < Hyprland.workspaces.length; i++)
                                ws.push(Hyprland.workspaces[i])
                            ws.sort(function(a, b) { return a.id - b.id })
                            return ws
                        }

                        delegate: Item {
                            id: wsDot
                            required property var modelData
                            visible: modelData.id > 0
                            Layout.alignment: Qt.AlignVCenter

                            property bool active: Hyprland.focusedWorkspace !== null
                                && modelData.id === Hyprland.focusedWorkspace.id
                            property int  wins: modelData.windows !== undefined
                                ? modelData.windows : 0

                            implicitHeight: 7
                            implicitWidth:  active ? 20 : 7

                            Behavior on implicitWidth {
                                SpringAnimation { spring: 6.0; damping: 0.60; mass: 0.5; epsilon: 0.3 }
                            }

                            Rectangle {
                                width:  wsDot.implicitWidth
                                height: 7
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3.5
                                color: wsDot.active   ? "#c792ea"
                                     : wsDot.wins > 0 ? Qt.rgba(1,1,1,0.60)
                                     :                  Qt.rgba(1,1,1,0.22)
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Behavior on width {
                                    SpringAnimation { spring: 6.0; damping: 0.60; mass: 0.5; epsilon: 0.3 }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + wsDot.modelData.id)
                            }
                        }
                    }
                }

                // ── Active window title ────────────────────────
                Text {
                    Layout.alignment:    Qt.AlignVCenter
                    Layout.maximumWidth: 200
                    text: {
                        var w = Hyprland.focusedWindow
                        if (!w) return ""
                        return (w.title !== undefined) ? w.title : ""
                    }
                    color: Qt.rgba(1,1,1,0.78)
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    visible: text.length > 0
                }

                // ── MPRIS ──────────────────────────────────────
                RowLayout {
                    spacing: 6
                    visible: root.mprisPlayer !== null
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle { width:1; height:20; radius:1; color:Qt.rgba(1,1,1,0.12) }

                    Text { text:"⏮"; font.pixelSize:11; color:Qt.rgba(1,1,1,0.60); Layout.alignment:Qt.AlignVCenter
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                            onClicked: { if (root.mprisPlayer) root.mprisPlayer.previous() } } }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        font.pixelSize: 13; color: Qt.rgba(1,1,1,0.92)
                        text: (root.mprisPlayer &&
                               root.mprisPlayer.playbackState === MprisPlaybackState.Playing)
                              ? "⏸" : "▶"
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                            onClicked: { if (root.mprisPlayer) root.mprisPlayer.togglePlaying() } }
                    }

                    Text { text:"⏭"; font.pixelSize:11; color:Qt.rgba(1,1,1,0.60); Layout.alignment:Qt.AlignVCenter
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                            onClicked: { if (root.mprisPlayer) root.mprisPlayer.next() } } }

                    Column {
                        spacing: 2; Layout.alignment: Qt.AlignVCenter; Layout.maximumWidth: 140

                        Text {
                            width: parent.width
                            text: root.mprisPlayer ? (root.mprisPlayer.trackTitle || "Unknown") : ""
                            color: Qt.rgba(1,1,1,0.92); font.pixelSize:11; font.weight:Font.Medium
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: root.mprisPlayer ? (root.mprisPlayer.trackArtist || "") : ""
                            color: Qt.rgba(1,1,1,0.45); font.pixelSize:9
                            elide: Text.ElideRight
                        }
                        Rectangle {
                            width: parent.width; height:2; radius:1; color:Qt.rgba(1,1,1,0.15)
                            Rectangle {
                                height:2; radius:1; color:"#c792ea"
                                width: {
                                    if (!root.mprisPlayer) return 0
                                    var len = root.mprisPlayer.length   || 0
                                    var pos = root.mprisPlayer.position || 0
                                    return len > 0 ? Math.min(1.0, pos / len) * parent.width : 0
                                }
                                Behavior on width { SmoothedAnimation { velocity: 25 } }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // ── System tray ────────────────────────────────
                Repeater {
                    model: SystemTray.items
                    delegate: Item {
                        id: trayDel
                        required property SystemTrayItem modelData
                        implicitWidth: 18; implicitHeight: 18
                        Layout.alignment: Qt.AlignVCenter
                        Image {
                            anchors.centerIn:parent; width:16; height:16
                            source: trayDel.modelData.icon
                            fillMode: Image.PreserveAspectFit; smooth:true
                        }
                        MouseArea {
                            anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: trayDel.modelData.activate(0, 0)
                        }
                    }
                }

                // ── GPU (only rendered if GPUs detected) ───────
                Repeater {
                    model: root.gpuList
                    delegate: Column {
                        id: gpuCol
                        required property var modelData
                        spacing:0; Layout.alignment:Qt.AlignVCenter
                        Text { anchors.horizontalCenter:parent.horizontalCenter
                            text:gpuCol.modelData.name; color:Qt.rgba(1,1,1,0.40)
                            font.pixelSize:8; font.weight:Font.Medium }
                        Text { anchors.horizontalCenter:parent.horizontalCenter
                            text:(gpuCol.modelData.usage||0)+"%"
                            font.pixelSize:12; font.weight:Font.DemiBold
                            color:(gpuCol.modelData.usage||0)>80?"#ff6b6b":
                                  (gpuCol.modelData.usage||0)>50?"#ffd93d":Qt.rgba(1,1,1,0.90)
                            Behavior on color { ColorAnimation { duration:500 } } }
                    }
                }

                // ── CPU ────────────────────────────────────────
                Column {
                    spacing:0; Layout.alignment:Qt.AlignVCenter
                    Text { anchors.horizontalCenter:parent.horizontalCenter; text:"CPU"
                        color:Qt.rgba(1,1,1,0.40); font.pixelSize:8; font.weight:Font.Medium }
                    Text { anchors.horizontalCenter:parent.horizontalCenter
                        text:root.cpuUsage+"%"; font.pixelSize:12; font.weight:Font.DemiBold
                        color:root.cpuUsage>80?"#ff6b6b":root.cpuUsage>50?"#ffd93d":Qt.rgba(1,1,1,0.90)
                        Behavior on color { ColorAnimation { duration:500 } } }
                }

                // ── RAM ────────────────────────────────────────
                Column {
                    spacing:0; Layout.alignment:Qt.AlignVCenter
                    Text { anchors.horizontalCenter:parent.horizontalCenter; text:"RAM"
                        color:Qt.rgba(1,1,1,0.40); font.pixelSize:8; font.weight:Font.Medium }
                    Text { anchors.horizontalCenter:parent.horizontalCenter
                        text:root.ramUsage+"%"; font.pixelSize:12; font.weight:Font.DemiBold
                        color:root.ramUsage>80?"#ff6b6b":root.ramUsage>60?"#ffd93d":Qt.rgba(1,1,1,0.90)
                        Behavior on color { ColorAnimation { duration:500 } } }
                }

                Rectangle { width:1; height:20; radius:1; color:Qt.rgba(1,1,1,0.12); Layout.alignment:Qt.AlignVCenter }

                // ── Brightness ─────────────────────────────────
                Text { text:"☀"; font.pixelSize:13; color:Qt.rgba(1,1,1,0.65); Layout.alignment:Qt.AlignVCenter }

                Slider {
                    id: brightSlider
                    from:1; to:100; padding:0
                    implicitWidth:60; implicitHeight:20
                    Layout.alignment:Qt.AlignVCenter
                    Binding { target:brightSlider; property:"value"; value:root.brightPct; when:!brightSlider.pressed }
                    onMoved: {
                        brightSetProc.val = Math.round(value) + "%"
                        root.runOnce(brightSetProc)
                    }
                    background: Rectangle {
                        x:brightSlider.leftPadding
                        y:brightSlider.topPadding+(brightSlider.availableHeight-height)/2
                        width:brightSlider.availableWidth; height:4; radius:2; color:Qt.rgba(1,1,1,0.12)
                        Rectangle {
                            width:brightSlider.visualPosition*parent.width; height:4; radius:2; color:"#ffd93d"
                            Behavior on width { SpringAnimation { spring:6; damping:0.75; epsilon:0.5 } }
                        }
                    }
                    handle: Rectangle {
                        x:brightSlider.leftPadding+brightSlider.visualPosition*(brightSlider.availableWidth-width)
                        y:brightSlider.topPadding+(brightSlider.availableHeight-height)/2
                        width:14; height:14; radius:7; color:"white"
                        Behavior on x { SpringAnimation { spring:6; damping:0.75; epsilon:0.5 } }
                    }
                }

                // ── Volume ─────────────────────────────────────
                Text {
                    text:root.muted?"🔇":root.volumePct>66?"🔊":root.volumePct>33?"🔉":root.volumePct>0?"🔈":"🔇"
                    font.pixelSize:14; Layout.alignment:Qt.AlignVCenter
                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                        onClicked: { root.muted = !root.muted; root.runOnce(muteProc) } }
                }

                Slider {
                    id: volSlider
                    from:0; to:100; padding:0
                    implicitWidth:60; implicitHeight:20
                    Layout.alignment:Qt.AlignVCenter
                    Binding { target:volSlider; property:"value"; value:root.volumePct; when:!volSlider.pressed }
                    onMoved: {
                        volSetProc.pct = Math.round(value) + "%"
                        root.runOnce(volSetProc)
                    }
                    background: Rectangle {
                        x:volSlider.leftPadding
                        y:volSlider.topPadding+(volSlider.availableHeight-height)/2
                        width:volSlider.availableWidth; height:4; radius:2; color:Qt.rgba(1,1,1,0.12)
                        Rectangle {
                            width:volSlider.visualPosition*parent.width; height:4; radius:2
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

                // ── Clock (12-hour) ────────────────────────────
                Column {
                    spacing:1; Layout.alignment:Qt.AlignVCenter
                    Text { anchors.horizontalCenter:parent.horizontalCenter
                        text:Qt.formatTime(clock.date,"h:mm AP")
                        color:Qt.rgba(1,1,1,0.95); font.pixelSize:13; font.weight:Font.DemiBold }
                    Text { anchors.horizontalCenter:parent.horizontalCenter
                        text:Qt.formatDate(clock.date,"ddd, MMM d")
                        color:Qt.rgba(1,1,1,0.45); font.pixelSize:9 }
                }

                // ── Power button ───────────────────────────────
                Rectangle {
                    id: powerBtn
                    Layout.alignment:Qt.AlignVCenter
                    width:26; height:26; radius:13
                    color:powerMa.containsMouse?Qt.rgba(1,0.15,0.15,0.40):Qt.rgba(1,1,1,0.08)
                    Behavior on color { ColorAnimation { duration:150 } }
                    scale: 1.0
                    Behavior on scale { SpringAnimation { spring:10; damping:0.40; mass:0.5 } }

                    Text { anchors.centerIn:parent; text:"⏻"; font.pixelSize:13
                        color:powerMa.containsMouse?"#ff6b6b":Qt.rgba(1,1,1,0.65)
                        Behavior on color { ColorAnimation { duration:150 } } }

                    Timer { id:bounceTimer; interval:90; onTriggered: powerBtn.scale = 1.0 }

                    MouseArea {
                        id:powerMa; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                        onClicked: {
                            powerBtn.scale = 0.78
                            bounceTimer.restart()
                            root.powerMenuOpen = !root.powerMenuOpen
                        }
                    }
                }

            } // RowLayout
        } // pill
    } // bar

    // ─────────────────────────────────────────────────────────
    //  POWER MENU POPUP
    //  Slides out from behind the bar with OutBack overshoot.
    //  Slides back up behind the bar on close (InCubic).
    //  Uses menuClosing flag so the close animation fully plays.
    // ─────────────────────────────────────────────────────────
    PanelWindow {
        id: powerPopup
        visible:       root.powerMenuOpen || root.menuClosing
        anchors.top:   true
        anchors.right: true
        implicitWidth:  192
        implicitHeight: 310
        color:          "transparent"
        exclusiveZone:  0

        // closedY = tucked behind bar; openY = just below bar
        readonly property real closedY: 2.0
        readonly property real openY:   58.0

        Rectangle {
            id: menuBox
            width:168; radius:10
            anchors.right:       parent.right
            anchors.rightMargin: 12
            height: menuCol.implicitHeight + 20
            color:        "#ee111827"
            border.color: Qt.rgba(1,1,1,0.10); border.width:1
            clip: true
            y:       powerPopup.closedY
            opacity: 0.0

            NumberAnimation { id:openSlide;  target:menuBox; property:"y";
                from:powerPopup.closedY; to:powerPopup.openY;
                duration:400; easing.type:Easing.OutBack; easing.overshoot:1.2 }
            NumberAnimation { id:openFade;   target:menuBox; property:"opacity";
                from:0.0; to:1.0; duration:200 }
            NumberAnimation { id:closeSlide; target:menuBox; property:"y";
                from:powerPopup.openY; to:powerPopup.closedY;
                duration:240; easing.type:Easing.InCubic;
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
                        id: mRow
                        required property var modelData
                        width:parent.width; height:36; radius:7
                        color:rowHov.containsMouse?Qt.rgba(1,1,1,0.12):"transparent"
                        Behavior on color { ColorAnimation { duration:120 } }
                        scale:rowHov.containsMouse?1.03:1.0
                        Behavior on scale { SpringAnimation { spring:8; damping:0.60 } }

                        RowLayout {
                            anchors.fill:parent; anchors.leftMargin:10; anchors.rightMargin:10; spacing:8
                            Text { text:mRow.modelData.emoji; font.pixelSize:16 }
                            Text { text:mRow.modelData.label; color:Qt.rgba(1,1,1,0.90)
                                font.pixelSize:13; Layout.fillWidth:true }
                        }

                        MouseArea {
                            id:rowHov; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
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
                    menuBox.y       = powerPopup.closedY
                    menuBox.opacity = 0.0
                    openSlide.start()
                    openFade.start()
                } else {
                    root.menuClosing = true
                    closeSlide.start()
                    closeFade.start()
                }
            }
        }
    } // powerPopup

} // ShellRoot
