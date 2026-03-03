{ config, lib, pkgs, ... }:
{
  programs.firefox.enable = false;
  programs.kdeconnect.enable = true;
  # programs.adb.enable = true; this is removed

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.05" ];

  services.flatpak.enable = true;

  # steam
  # programs.steam = {
  #   enable = true;
  #   gamescopeSession.enable = true;
  # };
  programs.gamemode.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Performance settings for faster builds
  nix.settings.max-jobs = 4;  # Number of parallel build jobs (adjust based on CPU cores)
  nix.settings.cores = 0;     # 0 = use all available cores per job

  # Add fast binary cache (Cachix community cache)
  nix.settings.trusted-substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
}
