{
  description = "my nix-config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs = {
        nixpkgs-lib.follows = "nixpkgs";
      };
    };
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager/trunk";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    nix-flatpak.url = "github:hnjae/nix-flatpak";
    nix-web-app.url = "/home/hyunjae/Projects/nix-web-app";
    impermanence.url = "github:nix-community/impermanence";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-mozilla.url = "github:mozilla/nixpkgs-mozilla";
    # nur.url = "github:nix-community/NUR";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "flake-compat";
      };
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # base16
    base16.url = "github:SenchoPens/base16.nix";
    base16-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    # https://github.com/chriskempson/base16-templates-source/blob/master/list.yaml
    base24-konsole = {
      url = "github:Base24/base24-konsole";
      flake = false;
    };
    base24-kdeplasma = {
      url = "github:Base24/base24-kdeplasma";
      flake = false;
    };
    base24-vscode-terminal = {
      url = "github:Base24/base24-vscode-terminal";
      flake = false;
    };
    base24-kate = {
      url = "github:Base24/base24-kate";
      flake = false;
    };

    # to fix duplictae dependencies
    git-hooks = {
      # url = "github:cachix/git-hooks.nix";
      follows = "nixvim/git-hooks";
    };
    flake-compat = {
      follows = "git-hooks/flake-compat";
    };
    devshell = {
      # url = "github:numtide/devshell";
      follows = "nixvim/devshell";
      inputs.flake-utils.follows = "flake-utils";
    };

    # others
    cgitc = {
      url = "github:hnjae/cgitc";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    flake-utils,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./apps/flake-module.nix
        ./packages/flake-module.nix

        ./modules/nixos/flake-module.nix
        ./modules/home-manager/flake-module.nix

        ./nixos-configs-sample/flake-module.nix
        ./hm-configs-sample/flake-module.nix
      ];
      systems = with flake-utils.lib.system; [
        x86_64-linux
        aarch64-darwin
        # aarch64-linux
      ];
      perSystem = {pkgs, ...}: {
        # Utilized by `nix develop`
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            sops

            # LSPs
            nil
            nixd

            # linters
            statix
            deadnix

            # formatters
            alejandra

            # just
            just
            parallel
            jq
          ];
        };

        # Utilized by `nix fmt`
        formatter = pkgs.alejandra;
      };
      flake = {
        overlays.default = _: prev: (
          if (builtins.hasAttr prev.stdenv.system self.packages)
          then
            # NOTE: 아래 방법을 사용하면 override 같은 것이 동작 안함 <2024-08-19>
            # prev.config.allowUnfree 값 전달 위한 코드
            # (builtins.mapAttrs (
            #     _: drv: (
            #       prev.stdenv.mkDerivation (
            #         drv.drvAttrs
            #         // {
            #           inherit (drv) meta;
            #         }
            #       )
            #     )
            #   )
            #   self.packages.${prev.stdenv.system})
            (
              builtins.mapAttrs (_: drv: drv)
              # 다음 방법을 사용하면 packages 를 선언하는 `pkgs` 는 `allowUnfree` 가 되어야한다.
              # 다만, overlays 단에서 unfree 를 필터링함으로, 의도하지 않은 unfree 패키지가 설치될 일은 없을것으로 기대된다.
              (
                prev.lib.filterAttrs
                (_: drv: (
                  prev.config.allowUnfree || (!drv.meta.unfree)
                ))
                self.packages.${prev.stdenv.system}
              )
            )
          else {}
        );
      };
    };
}
