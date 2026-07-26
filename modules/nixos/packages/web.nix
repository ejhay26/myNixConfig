{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # "php" + bare phpExtensions removed: they were a duplicate PHP installation
    # alongside php83. phpExtensions.* without a version prefix pull in a
    # different PHP version, causing two full PHP builds on disk. php83 with
    # its own extensions is the single source of truth.
    (php83.withExtensions ({ all, ... }: with all; [
      mysqli
      pdo
      pdo_mysql
      mbstring
      curl
      openssl
    ]))
    php83Packages.composer
    ionic-cli
  ];
}
