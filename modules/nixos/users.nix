{ config, lib, pkgs, ... }:
{
  users.users.terajaki = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "kvm" "adbusers" "input" "video" ];
    packages = with pkgs; [ tree ];
    shell = pkgs.zsh;
  };
}
