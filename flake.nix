{
  description = "my nix-config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.11";
      # url = "github:nixos/nixpkgs/?ref=b1b329146965";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs = {
        nixpkgs-lib.follows = "nixpkgs";
      };
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };
    crane.url = "github:ipetkov/crane";

    ############################################################################
    # nixosModules / homeManagerModule
    ############################################################################
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "z_rust-overlay";
        crane.follows = "crane";
        pre-commit.follows = "";
      };
    };
    disko = {
      # version checked 2025-08-02 <https://github.com/nix-community/disko/releases>
      url = "github:nix-community/disko/refs/tags/v1.12.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    microvm = {
      url = "github:astro/microvm.nix/refs/tags/v0.5.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-web-app.url = "github:hnjae/nix-web-app";
    quadlet-nix = {
      url = "github:SEIAROTg/quadlet-nix";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    xremap-nix = {
      url = "github:xremap/nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        crane.follows = "crane";
      };
    };

    ############################################################################
    # Overlays / Packages
    ############################################################################
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
        nuschtosSearch.follows = "";
      };
    };
    py-utils = {
      url = "git+ssh://git@github.com/hnjae/py-utils";
      # url = "path:/home/hnjae/Projects/py-utils";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "";
      };
    };
    yaml2nix = {
      # NOTE: yaml2nix 는 구조상 다음과 같이 선언해야 함. <2025-12-14>
      # https://github.com/euank/yaml2nix/blob/main/flake.nix
      url = "github:euank/yaml2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        cargo2nix.follows = "z_cargo2nix_0110";
        flake-utils.follows = "flake-utils";
      };
    };

    ############################################################################
    # Used as an input dependency only
    ############################################################################
    # https://github.com/NixOS/flake-registry 에 등재.
    systems.url = "github:nix-systems/default";

    # NOTE: `z_` prefix 는 hidden 이라는 의미임. `nix.nix` 에서 활용.
    z_cargo2nix_0110 = {
      url = "github:cargo2nix/cargo2nix/release-0.11.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "z_rust-overlay";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };
    z_rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake
      {
        inherit
          inputs
          ;
      }
      {
        imports = nixpkgs.lib.flatten [
          ./attributes/deploy.nix
          ./attributes/homeManagerModules.nix

          ./shared/flake-module.nix

          ./hosts/flake-module.nix

          ./apps/flake-module.nix
          ./hm-modules/flake-module.nix
          ./nixos-modules/flake-module.nix
          ./packages/flake-module.nix
          ./templates/flake-module.nix

          ./profiles/flake-module.nix
        ];
        systems = with flake-utils.lib.system; [
          x86_64-linux
          aarch64-darwin
        ];
        perSystem =
          {
            pkgs,
            ...
          }:
          {
            # Utilized by `nix develop`
            devShells.default = pkgs.mkShellNoCC {
              packages = with pkgs; [
                sops
                git-crypt

                # LSPs / Linters
                nil
                statix
                deadnix

                prek

                # Formatters
                nixfmt-rfc-style

                shellcheck
                shellharden
                shfmt
                fish # .fish

                yamlfix
                taplo # toml
                markdownlint-cli2 # .md
                biome # json

                # just
                just
                jq
                nushell # used in justfile

                # Used in other workspace
                cargo
                rustfmt
                ruff
              ];
            };
          };
      };
}
