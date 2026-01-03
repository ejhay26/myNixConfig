{ config, lib, pkgs, ... }:
{
  # ========== HOSTNAME ==========
  networking.hostName = "nixos";
  # Alternatively: networking.hostName = "your-hostname";

  # ========== NETWORK MANAGER ==========
  networking.networkmanager.enable = true;

  # ========== FIREWALL ==========
  networking.firewall.allowedTCPPorts = [ 3389 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # ========== NETWORK PROXY ==========
  # Uncomment and configure if needed:
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # ========== MISC NETWORKING ==========
  systemd.services.NetworkManager-wait-online.enable = false;
  services.journald.extraConfig = "SystemMaxUse=50M";
}
