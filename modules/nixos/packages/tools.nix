{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    git
    brave
    vivaldi
    fastfetch
    vscode-fhs
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
    guitarix
    kde-rounded-corners
    kdePackages.krdp
    mapscii
    vesktop
    qbittorrent
  ] ++ [
    inputs.kwin-effects-forceblur.packages.${pkgs.system}.default
    inputs.kwin-effects-glass.packages.${pkgs.system}.default
  ];
}
