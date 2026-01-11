{ config, lib, pkgs, ... }:
{
  # Bluetooth manager (GUI)
  # Provides a system tray icon and manager to pair devices
  services.blueman.enable = true;
  
  # ========== DATABASE ==========
  # MySQL / MariaDB
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings.mysqld = {
      port = 3306;
      bind-address = "127.0.0.1";
    };
  };

  # MongoDB
  services.mongodb = {
    enable = true;
    package = pkgs.mongodb-ce; #mongodb is not pre-compiled
    bind_ip = "127.0.0.1";
  };

  # ========== UDEV RULES ==========
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  # ========== PRINTING ==========
  # services.printing.enable = true;

  # ========== SSH DAEMON ==========
  # services.openssh.enable = true;
}
