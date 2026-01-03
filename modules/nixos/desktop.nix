{ config, lib, pkgs, ... }:
{
  time.timeZone = "Asia/Manila";

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;

  services.getty.autologinUser = null;
}
