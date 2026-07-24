{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    git
    brave
    vivaldi
#   librewolf
    fastfetch
    vscode-fhs
    figma-linux
    mongodb-compass
    libreoffice-qt6-fresh
    ttyper
    ani-cli
    mov-cli
    fzf
    yazi
    dotool
    scrcpy
    libdbusmenu
    libdbusmenu-gtk3
    gparted
    exfatprogs
    # wireshark - the package hash is currently broken, so it's commented out for now
    ntfs3g
    android-tools
    gptfdisk
    dmg2img
    ngrok
    # docker
    samba
    gnirehtet
    guitarix
    # kde-rounded-corners
    # kdePackages.krdp
    mapscii
    browsh
    vesktop # = this is the modified discord
    discord
    telegram-desktop
    qbittorrent
    proton-vpn
    easyeffects
    inkscape
    bibata-cursors
    papirus-icon-theme
    # thunar
    kdePackages.dolphin
    mission-center

  ] ++ [
    # inputs.kwin-effects-forceblur.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.kwin-effects-glass.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.openclaw.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.noctalia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Set Papirus as the default icon theme for GTK and Qt
  environment.variables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    GTK_ICON_THEME = "Papirus";
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "gtk2";
  };
}
