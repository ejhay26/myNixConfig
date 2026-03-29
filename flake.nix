{
  description = "my NixOS btw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # kwin-effects-forceblur = {
    #   url = "github:taj-ny/kwin-effects-forceblur";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # kwin-effects-glass = {
    #     url = "github:4v3ngR/kwin-effects-glass";
    #     inputs.nixpkgs.follows = "nixpkgs";
    #   };

    openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  # Added 'nur' to the arguments below so it's accessible in the modules
  outputs = { self, nixpkgs, home-manager, nur, hyprland, hyprland-plugins, , openclaw, noctalia-shell, ... }@inputs: { # kwin-effects-forceblur, # kwin-effects-glass
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.terajaki = import ./home.nix;
            extraSpecialArgs = { inherit inputs; }; # Recommended for home.nix
            backupFileExtension = "backup";
          };
        }

        # NUR Overlay Configuration
        {
          nixpkgs.overlays = [ nur.overlays.default ];
        }
      ];
    };
  };
}
