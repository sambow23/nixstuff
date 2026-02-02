{
  description = "NixOS Flake Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "github:sambow23/nixvim-config/rewrite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-flatpak,
    nix-vscode-extensions,
    neovim,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    # Define system architectures for each host
    systemFor = host: if host == "mbpvm" then "aarch64-linux" else "x86_64-linux";
    hostnames = ["mba" "hpg7" "p5540" "mainpc" "d3301" "mbpvm" "7400"];
    commonModules = [
      nix-flatpak.nixosModules.nix-flatpak
      {
        nixpkgs.overlays = [nix-vscode-extensions.overlays.default];
      }
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs neovim;
        };
        home-manager.users.cr = import ./main/home/home.nix;
      }
    ];
    mkSystem = hostname:
      lib.nixosSystem {
        system = systemFor hostname;  # Use the appropriate system for each host
        modules =
          [
            ./hosts/${hostname}/configuration.nix
            {home-manager.extraSpecialArgs.hostname = hostname;}
          ]
          ++ commonModules;
      };
  in {
    # Add formatter for both architectures
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
      aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
    };
    nixosConfigurations = lib.genAttrs hostnames mkSystem;
  };
}
