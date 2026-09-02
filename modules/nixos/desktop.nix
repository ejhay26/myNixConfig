
{ config, lib, pkgs, inputs, ... }:
{
  # ========== TIMEZONE & LOCALIZATION ==========
  time.timeZone = "Asia/Manila";
  time.hardwareClockInLocalTime = false;

  # ========== SECRET KEYRING & SECURITY ==========
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.dbus.packages = [ pkgs.gcr pkgs.kdePackages.kio-extras ];

  # ========== DESKTOP ENVIRONMENT & GREETER ==========
  # ReGreet: clean GTK greeter running under cage (mini Wayland compositor)
  # No terminal flash, proper cursor, easy session dropdown
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        fit = "Cover";
      };
      GTK = {
        cursor_theme_name = lib.mkForce "Bibata-Modern-Classic";
        icon_theme_name = lib.mkForce "Papirus";
        theme_name = lib.mkForce "Adwaita-dark";
      };
      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };
    };
    cageArgs = [ "-s" "-m" "last" ];
  };

  # Expose Wayland session packages to greetd (Hyprland, Niri, MangoWC)
  services.displayManager.sessionPackages = [
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
    inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri
    inputs.mangowc.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

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

  # ========== STORAGE & DEVICE MOUNTING (MTP / ANDROID / USB) ==========
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

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
