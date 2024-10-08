{
  description = "NixOS Flake Config";
  # nixConfig = {
  #   extra-substituters = [
  #     "https://nix-community.cachix.org"
  #   ];
  #   extra-trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #   ];
  # };

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

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-index-database,
    nix-vscode-extensions,
    nix-flatpak,
    ...
  } @ inputs: {
    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations = {
      # 2017 11-inch MacBook Air
      mba = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/mba/configuration.nix
          nix-flatpak.nixosModules.nix-flatpak
          {
            nixpkgs.overlays = [inputs.nix-vscode-extensions.overlays.default];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hostname = "mba";
              inherit inputs;
            };
            home-manager.users.cr = import ./main/home/home.nix;
          }
        ];
      };

      # HP ZBook Firefly 14 G7
      hpg7 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/hpg7/configuration.nix
          nix-flatpak.nixosModules.nix-flatpak
          {
            nixpkgs.overlays = [inputs.nix-vscode-extensions.overlays.default];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hostname = "hpg7";
              inherit inputs;
            };
            home-manager.users.cr = import ./main/home/home.nix;
          }
        ];
      };

      # Dell Precision 5540
      p5540 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/p5540/configuration.nix
          nix-flatpak.nixosModules.nix-flatpak
          {
            nixpkgs.overlays = [inputs.nix-vscode-extensions.overlays.default];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hostname = "p5540";
              inherit inputs;
            };
            home-manager.users.cr = import ./main/home/home.nix;
          }
        ];
      };

      # Main Workstation PC
      mainpc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/mainpc/configuration.nix
          nix-flatpak.nixosModules.nix-flatpak
          {
            nixpkgs.overlays = [inputs.nix-vscode-extensions.overlays.default];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hostname = "mainpc";
              inherit inputs;
            };
            home-manager.users.cr = import ./main/home/home.nix;
          }
        ];
      };
    };
  };
}
