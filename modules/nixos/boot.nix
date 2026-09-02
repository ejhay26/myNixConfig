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
      efi.canTouchEfiVariables = false;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    consoleLogLevel = 0;

    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
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
  
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 50;
    priority = 100;
  };

  # Sync rEFInd configuration and Gruvbox theme assets to ESP during system rebuilds
  system.activationScripts.refindConfig = ''
    if [ -d /boot/EFI/refind ]; then
      cp -f /home/terajaki/nixos/modules/nixos/refind/refind.conf /boot/EFI/refind/refind.conf
      mkdir -p /boot/EFI/refind/gruvbox
      cp -r -f /home/terajaki/nixos/modules/nixos/refind/gruvbox/* /boot/EFI/refind/gruvbox/
      mkdir -p /boot/EFI/BOOT
      cp -f /boot/EFI/refind/refind_x64.efi /boot/EFI/BOOT/BOOTX64.EFI 2>/dev/null || true
    fi
  '';
}
