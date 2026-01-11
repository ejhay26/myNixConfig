{ config, lib, pkgs, ... }:
{
  # Enable Bluetooth hardware support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

}