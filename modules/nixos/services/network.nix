{ config, lib, pkgs, ... }:
{
  services.create_ap = {
    enable = true;
    wifiInterface = "wlan0";       # your Wi-Fi interface
    internetInterface = "enp1s0";    # your internet interface
    ssid = "nixos";
    passphrase = "88888888";
    settings = {
      FREQ_BAND = 5;
      COUNTRY = "PH";
    };
  };
}
