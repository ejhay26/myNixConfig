{ config, lib, pkgs, ... }: 
{
  programs = {
    firefox.enable = true; 
    kdeconnect.enable = true; 
    # adb.enable = true; this is already deprecated in favor of the new android-tools pacakage.

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    gpu-screen-recorder.enable = true;
    zsh.enable = true;
    gamemode.enable = true;

    # steam
    # steam = {
    #   enable = true;
    #   gamescopeSession.enable = true; 
    # };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "ventoy-1.1.05" ]; 
    };
  };

  services = {
    flatpak.enable = true;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];

      # Performance settings for faster builds
      max-jobs = 4; # Number of parallel build jobs (adjust based on CPU cores)
      cores = 0; # 0 = use all available cores per job
      download-buffer-size = 524288000; # 500 MB

      # Add fast binary cache (Cachix community cache)
      trusted-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}