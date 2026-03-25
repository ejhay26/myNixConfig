{ config, lib, pkgs, ... }:
{
  services = {
    "power-profiles-daemon".enable = true;
    # tuned.enable = true;
    upower.enable = true;

    # Uncomment the following if you want these services quickly togglable
    # printing.enable = true;
    # openssh.enable = true;
  };
}
