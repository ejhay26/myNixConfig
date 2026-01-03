{ config, lib, pkgs, ... }:
{
  imports = [
    ./server.nix
    ./setup.nix
  ];
}
