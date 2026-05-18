{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wine
    wineWow64Packages.full
    mangohud
    # protonup
  ];
}
