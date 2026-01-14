{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    git
    brave
    vivaldi
    fastfetch
    vscode-fhs
    mongodb-compass
    libreoffice-qt6-fresh
    ttyper
    ani-cli
    mov-cli
    dotool
    scrcpy
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
    vesktop
    telegram-desktop
    qbittorrent
    easyeffects
    inkscape
  ] ++ [
    inputs.kwin-effects-forceblur.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.kwin-effects-glass.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
