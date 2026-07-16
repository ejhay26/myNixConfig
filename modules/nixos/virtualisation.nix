{ config, lib, pkgs, ... }:
{
  virtualisation = {
    libvirtd.enable = true;
    kvmgt.enable = true;
    spiceUSBRedirection.enable = true;

    #  Docker
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };

    #  Waydroid
     waydroid.= {
      enable = true;
      package = pkgs.waydroid-nftables;
     };
  };
  programs.virt-manager.enable = true;
}
