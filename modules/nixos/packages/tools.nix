{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    git
    brave
    vivaldi
    librewolf
    fastfetch
    vscode-fhs
    figma-linux
    mongodb-compass
    libreoffice-qt6-fresh
    ttyper
    ani-cli
    mov-cli
    dotool
    scrcpy
    libdbusmenu
    libdbusmenu-gtk3
    gparted
    exfatprogs
    ntfs3g
    android-tools
    gptfdisk
    dmg2img
    ngrok
    samba
    gnirehtet
    # guitarix
    kde-rounded-corners
    kdePackages.krdp
    mapscii
    browsh
    vesktop
    telegram-desktop
    qbittorrent
    protonvpn-gui
    easyeffects
    inkscape
  ] ++ [
    inputs.kwin-effects-forceblur.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.kwin-effects-glass.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
