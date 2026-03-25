{ config, lib, pkgs, ... }:
{
  # Entrypoint for service module category.
  # Breaks configuration into more manageable submodules.
  imports = [
    ./databases.nix
    ./udev.nix
    ./power.nix
  ];
}

