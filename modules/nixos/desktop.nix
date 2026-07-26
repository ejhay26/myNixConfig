
{ config, lib, pkgs, inputs, ... }:
{
  # ========== TIMEZONE & LOCALIZATION ==========
  time.timeZone = "Asia/Manila";
  time.hardwareClockInLocalTime = true;

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

  # Plasma6 removed — saves ~3-4GB of KDE framework.
  # SDDM runs standalone; Dolphin is installed directly as a package.
  # Power management via power-profiles-daemon + upower in services/power.nix.
  # services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;

  services.getty.autologinUser = null;
  
  # Hyprland
  programs.hyprland = {
    enable = true;
    # Sync the system-wide package with the flake input used in home.nix to prevent installing two versions
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    plugins = [
#      inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
#     inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    ];
  };

  # Niri
  programs.niri = {
    enable = true;
    # Use the bleeding-edge flake package for Niri
    package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri;
  };


  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable the XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk      # Useful for file pickers and some fallback
    ];
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
      # kde.default = [ "kde" ];
    };
  };

  # Set Bibata cursor as system-wide default (for login screen and greeters)
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };
}
