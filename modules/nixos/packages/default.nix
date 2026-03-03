{ config, lib, pkgs, ... }:
{
  imports = [
    ./development.nix
    ./databases.nix
    ./multimedia.nix
    ./gaming.nix
    ./web.nix
    ./tools.nix
    ./graphics-libs.nix
    ./hyprland-packages.nix
  ];

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
}
