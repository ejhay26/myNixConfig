{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wine
    wineWowPackages.full
    mangohud
    # protonup
  ];
}
