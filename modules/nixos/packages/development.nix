{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gcc
    rustc
    cargo
    pkg-config
    openssl
    python3
    python313Packages.pip
    tk
    clang
    cmake
    gnumake
    lld
    nodejs_24
  ];
}
