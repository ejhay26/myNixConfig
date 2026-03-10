{ config, lib, inputs, pkgs, ... }:
{
  # ============================================================================
  # NixOS System Configuration (Modularized)
  # ============================================================================
  # This configuration imports specialized modules for different system aspects.
  # Each module is self-contained and handles a specific concern.

  imports = [
    # Hardware configuration (generated during installation)
    ./hardware-configuration.nix

    # ========== BOOT & KERNEL ==========
    # Boot loader, kernel parameters, and module configuration
    ./modules/nixos/boot.nix

    # ========== NETWORKING ==========
    # Hostname, NetworkManager, firewall rules
    ./modules/nixos/networking.nix

    # ========== DESKTOP ENVIRONMENT ==========
    # Plasma 6, SDDM display manager, timezone
    ./modules/nixos/desktop.nix

    # ========== AUDIO SYSTEM ==========
    # PipeWire audio server, ALSA, JACK support
    ./modules/nixos/audio.nix

    # ========== USER MANAGEMENT ==========
    # User accounts and group memberships
    ./modules/nixos/users.nix

    # ========== VIRTUALIZATION ==========
    # KVM, libvirtd, virt-manager for VM support
    ./modules/nixos/virtualisation.nix

    # ========== GRAPHICS ==========
    # GPU drivers, 32-bit support, VDPAU
    ./modules/nixos/graphics.nix

    # ========== HARDWARE ==========
    # Bluetooth support
    ./modules/nixos/bluetooth.nix

    # ========== SYSTEM PROGRAMS ==========
    # Firefox, direnv, Flatpak, nixpkgs config
    ./modules/nixos/programs.nix

    # ========== SERVICES ==========
    # System services (Databases, udev rules)
    ./modules/nixos/services
      
    # ========== PACKAGES ==========
    # System packages organized by category (development, multimedia, etc.)
    ./modules/nixos/packages

    # ========== WEB SERVER & SETUP ==========
    # Apache/PHP configuration, virtual hosts, web directories
    ./modules/nixos/web
  ];

  # System state version (don't change unless upgrading NixOS)
  system.stateVersion = "25.11";
}
