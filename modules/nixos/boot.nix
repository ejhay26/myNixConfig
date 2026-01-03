{ config, lib, pkgs, ... }:
{
  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "evdev" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.systemd.show_status=auto"
    "udev.log_priority=3"
    "vt.global_cursor_default=0"
    "nowatchdog"
  ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel model=dell-headset-multi
  '';
  boot.supportedFilesystems = [ "ntfs" "exfat" ];
  boot.kernelModules = [ "usb_storage" "uas" "sd_mod" "sg" ];
}
