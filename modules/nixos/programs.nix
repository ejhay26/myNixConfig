{ config, lib, pkgs, ... }:
{
  programs.firefox.enable = false;
  programs.kdeconnect.enable = true;
  programs.adb.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.05" ];

  services.flatpak.enable = true;

  # steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
