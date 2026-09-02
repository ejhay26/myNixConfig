
{ config, lib, pkgs, inputs, ... }:
{
  # ========== TIMEZONE & LOCALIZATION ==========
  time.timeZone = "Asia/Manila";
  time.hardwareClockInLocalTime = false;

  # ========== SECRET KEYRING & SECURITY ==========
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.dbus.packages = [ pkgs.gcr ];

  # ========== DESKTOP ENVIRONMENT & GREETER ==========
  # Enable SDDM with Wayland support (seamless DRM transitions, no terminal flashing, proper cursor & resolution)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      Theme = {
        CursorTheme = "Bibata-Modern-Classic";
      };
    };
  };

  # Expose Wayland session packages to SDDM (Hyprland, Niri, MangoWC)
  services.displayManager.sessionPackages = [
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
    inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri
    inputs.mangowc.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  services.greetd.enable = false;
  programs.regreet.enable = false;

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

  # MangoWC, Security, Keyring & Storage Utilities
  environment.systemPackages = [
    pkgs.cage
    pkgs.seahorse
    pkgs.libsecret
    pkgs.gcr
    pkgs.hyprpolkitagent
    pkgs.ntfs3g
    pkgs.libmtp
    pkgs.android-file-transfer
    pkgs.kdePackages.kio-extras
    inputs.mangowc.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

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
