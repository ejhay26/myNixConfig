{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wine
    wineWowPackages.full
    gamemode
    obs-studio
  ];
}
