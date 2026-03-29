{ config, lib, pkgs, inputs, ... }:
{
  # ========== TIMEZONE & LOCALIZATION ==========
  time.timeZone = "Asia/Manila";
  # Alternatively: time.timeZone = "Europe/Amsterdam";

  # ========== INTERNATIONALISATION ==========
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true;
  # };

  # ========== X11 KEYMAP ==========
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # ========== DESKTOP ENVIRONMENT ==========
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.sddm.enable = true;

  services.getty.autologinUser = null;
  
  # Hyprland
  programs.hyprland = {
    enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable the XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland # Handles screen sharing for Hyprland
      pkgs.xdg-desktop-portal-gtk      # Useful for file pickers and some fallback
    ];
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
      # kde.default = [ "kde" ];
    };
  };

}
