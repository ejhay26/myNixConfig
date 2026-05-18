{ config, pkgs, ... }:
{
  # Additional packages used by Niri
  environment.systemPackages = with pkgs; [
    xwayland-satellite # X11 compatibility layer for Niri
    # Add any other Niri-specific utilities here if needed
  ];
}