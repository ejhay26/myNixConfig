{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    php
    phpExtensions.mysqli
    phpExtensions.pdo
    phpExtensions.pdo_mysql
    phpExtensions.mbstring
    phpExtensions.curl
    phpExtensions.openssl
    php83
    php83Packages.composer
  ];
}
