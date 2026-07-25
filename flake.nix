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

    niri = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-init = {
    #   url = "github:nix-community/nix-init";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # kwin-effects-forceblur = {
    #   url = "github:taj-ny/kwin-effects-forceblur";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # kwin-effects-glass = {
    #     url = "github:4v3ngR/kwin-effects-glass";
    #     inputs.nixpkgs.follows = "nixpkgs";
    #   };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
   
    caelestia = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # inir = {
    #   url = "github:snowarch/iNiR";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

  };


  outputs = { self, nixpkgs, home-manager, nur, hyprland, hyprland-plugins, noctalia-shell, niri, ... }@inputs: { # Note: kwin-effects-forceblur and kwin-effects-glass are currently not used, but I want to keep them here for future reference.
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        hyprland.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.terajaki = import ./home.nix;
            extraSpecialArgs = { 
              inherit inputs; 
            #  inir-fixed = inir.packages.x86_64-linux.default.overrideAttrs (oldAttrs: {
            #    dontPatchShebangs = true;
            #  });  
            }; # Recommended for home.nix
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
