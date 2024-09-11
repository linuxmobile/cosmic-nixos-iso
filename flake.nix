{
  description = "Live environment for nixos-cosmic.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    accept-flake-config = true;

    extra-substituters = [
      "https://cosmic.cachix.org/"
    ];

    extra-trusted-public-keys = [
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
    ];
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      overlay-unstable = final: prev: {
        zed-editor = pkgs-unstable.zed-editor;
      };
    in {
      nixosConfigurations = {
        cosmicIso = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-unstable ];
            })
            ./config
            self.inputs.nixos-cosmic.nixosModules.default
          ];
        };

        cosmicIso-edge = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-unstable ];
            })
            ./config
            ./config/edge-linux.nix
            self.inputs.nixos-cosmic.nixosModules.default
          ];
        };

        cosmicIso-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-unstable ];
            })
            ./config
            ./config/vm.nix
            self.inputs.nixos-cosmic.nixosModules.default
          ];
        };
      };
    };
}