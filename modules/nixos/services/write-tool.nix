{ config, lib, pkgs, ... }:
{
  services = {
    gvfs.enable = true;
  };
  environment.systemPackages = with pkgs; [
  gvfs-fuse jmtpfs
  ];
}
