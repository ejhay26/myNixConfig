{ config, lib, pkgs, ... }:
{
  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = [ "evdev" ];
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 1;
      };
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };

    zramSwap = {
      enable = true;
      algorithm = "lz4";       # Options include "lz4", "zstd", "lzo"
      memoryPercent = 50;      # Max RAM percentage ZRAM can use (e.g., 50%)
      priority = 100;          # Higher priority tells the system to use ZRAM first
    };


    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=auto"
      "udev.log_priority=3"
      "vt.global_cursor_default=0"
      "nowatchdog"
    ];

    extraModprobeConfig = ''
      options snd_hda_intel model=dell-headset-multi
    '';

    supportedFilesystems = [ "ntfs" "exfat" ];
    
    kernelModules = [ "usb_storage" "uas" "sd_mod" "sg" ];

    # Enable Plymouth for boot splash screen
    plymouth = {
      enable = true;
      theme = "bgrt"; #bgrt is the default theme
      themePackages = with pkgs; [
        # By default we only have the themes in the plymouth package.
        # You can add other packages here.
        adi1090x-plymouth-themes
        # spinfinity-plymouth-themes
      ];
    };
  };
}
