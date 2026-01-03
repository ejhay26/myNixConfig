{ config, lib, pkgs, ... }:
{
  virtualisation = {
    libvirtd.enable = true;
    kvmgt.enable = true;
    spiceUSBRedirection.enable = true;
  };
  programs.virt-manager.enable = true;
}
