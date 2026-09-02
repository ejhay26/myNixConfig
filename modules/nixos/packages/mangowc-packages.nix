{ config, inputs, pkgs, ... }:
{
  # Packages used by MangoWC
  environment.systemPackages = with pkgs; [
    inputs.mangowc.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
