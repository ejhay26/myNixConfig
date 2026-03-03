{ config, lib, pkgs, ... }:
{
  virtualisation = {
    libvirtd.enable = true;
    kvmgt.enable = true;
    spiceUSBRedirection.enable = true;

    #  Waydroid
#     waydroid.enable = true;
  };
  programs.virt-manager.enable = true;
}
