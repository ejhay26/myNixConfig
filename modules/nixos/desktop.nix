
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
  # tuigreet: clean, beautiful TUI greeter for greetd styled in Gruvbox dark theme
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-user-session --user-menu --kb-sessions 3 --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions --theme 'border=d79921;title=fabd2f;prompt=83a598;time=b8bb26;action=fe8019;button=fabd2f;container=282828;input=ebdbb2'";
        user = "greeter";
      };
    };
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
