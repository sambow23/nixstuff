{
  description = "NixOS Flake Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Pinned nixpkgs for t14s kernel - prevents rebuilds when main nixpkgs updates
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "github:sambow23/nixvim-config/rewrite";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixvim.inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixvim.inputs.home-manager.follows = "home-manager";
    };

    x1e-nixos-config = {
      url = "github:sambow23/x1e-nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # jglathe kernel source for t14s - pinned separately to avoid rebuilds on nixpkgs updates
    jglathe-kernel-src = {
      url = "github:jglathe/linux_ms_dev_kit/jg/ubuntu-qcom-x1e-6.19.6-jg-6";
      flake = false;
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    snowflakes = {
      url = "github:DuCanhGH/snowflakes";
      flake = false;
    };

    # Aero theme source repos
    aerothemeplasma = {
      url = "github:rustussy/aerothemeplasma";
      flake = false;
    };
    aero-libplasma = {
      url = "github:rustussy/aeroshell-libplasma";
      flake = false;
    };
    aero-workspace = {
      url = "github:rustussy/aeroshell-workspace";
      flake = false;
    };
    aero-kwin = {
      url = "github:rustussy/aeroshell-kwin-components";
      flake = false;
    };
    aero-smod = {
      url = "github:rustussy/aeroshell-smod";
      flake = false;
    };
    uac-polkit-agent = {
      url = "github:rustussy/uac-polkit-agent";
      flake = false;
    };
    plymouth-vista = {
      url = "github:rustussy/plymouth-vista";
      flake = false;
    };

    helium = {
      url = "github:AlvaroParker/helium-nix";
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
    x1e-nixos-config,
    plasma-manager,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    # Define system architectures for each host
    systemFor = host: if (host == "mbpvm" || host == "t14s") then "aarch64-linux" else "x86_64-linux";
    hostnames = ["mba" "hpg7" "p5540" "mainpc" "d3301" "mbpvm" "7400" "t14s"];
    commonModules = [
      nix-flatpak.nixosModules.nix-flatpak
      {
        nixpkgs.overlays = [
          nix-vscode-extensions.overlays.default
          (import ./packages/overlay.nix)
          (import "${inputs.snowflakes}/modules/nixos/overlays/repos.nix" { inherit inputs; })
        ];
      }
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs neovim;
        };
        home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
        home-manager.users.cr = import ./main/home/home.nix;
      }
    ];
    mkSystem = hostname:
      lib.nixosSystem {
        system = systemFor hostname;  # Use the appropriate system for each host
        specialArgs = { inherit inputs; };
        modules =
          [
            ./hosts/${hostname}/configuration.nix
            {home-manager.extraSpecialArgs.hostname = hostname;}
          ]
          ++ commonModules
          ++ (if hostname == "t14s" then [x1e-nixos-config.nixosModules.x1e] else []);
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
