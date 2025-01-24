{
  description = "my nix-config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs = {
        nixpkgs-lib.follows = "nixpkgs";
      };
    };
    flake-utils.url = "github:numtide/flake-utils";

    ############################################################################
    # nixosModules / homeManagerModule
    ############################################################################
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        rust-overlay.follows = "rust-overlay";
        flake-compat.follows = "";
        pre-commit-hooks-nix.follows = "";
      };
    };
    microvm = {
      url = "github:astro/microvm.nix/refs/tags/v0.5.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nix-flatpak.url = "github:hnjae/nix-flatpak";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-modules-private = {
      # url = "git+ssh://git@github.com/hnjae/nix-modules-private";
      # url = "git:/home/hnjae/Projects/nix-modules-private";
      url = "path:/home/hnjae/Projects/nix-modules-private";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        flake-parts.follows = "flake-parts";
        sops-nix.follows = "sops-nix";
      };
    };
    nix-web-app.url = "github:hnjae/nix-web-app";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    ############################################################################
    # Overlays / Packages
    ############################################################################
    nixpkgs-mozilla.url = "github:mozilla/nixpkgs-mozilla";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-parts.follows = "flake-parts";
        devshell.follows = "";
        flake-compat.follows = "";
        git-hooks.follows = "";
        nix-darwin.follows = "";
        nuschtosSearch.follows = "";
        treefmt-nix.follows = "";
      };
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "";
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ############################################################################
    # Base16
    # https://github.com/chriskempson/base16-templates-source/blob/master/list.yaml
    ############################################################################
    base16.url = "github:SenchoPens/base16.nix";
    base16-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    base24-vscode-terminal = {
      url = "github:Base24/base24-vscode-terminal";
      flake = false;
    };

    ############################################################################
    # formatters
    ############################################################################
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      flake-utils,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        imports = [
          treefmt-nix.flakeModule
          ./flake-output-attributes

          ./apps/flake-module.nix
          ./hosts/flake-module.nix
          ./packages/flake-module.nix
          ./templates/flake-module.nix

          ./modules/base/flake-module.nix
          ./modules/gnome/flake-module.nix
          ./modules/nixosModules/flake-module.nix
        ];
        systems = with flake-utils.lib.system; [
          x86_64-linux
          aarch64-darwin
        ];
        perSystem =
          { pkgs, ... }:
          {
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

                # just
                just
                parallel
                jq
              ];
            };

            # Utilized by `nix fmt` (formatter)
            treefmt.config = {
              projectRootFile = "flake.nix";
              programs = {
                nixfmt = {
                  enable = true;
                  package = pkgs.nixfmt-rfc-style;
                };
                fish_indent.enable = true;
                just.enable = true;
                mdformat.enable = true;
                ruff-format.enable = true;
                taplo.enable = true;
                yamlfmt.enable = true;
                shellcheck.enable = true;
                shfmt = {
                  enable = true;
                  indent_size = 2;
                };
                stylua = {
                  enable = true;
                  settings = {
                    column_width = 80;
                    indent_type = "Spaces";
                    indent_width = 2;
                  };
                };
              };
              settings = {
                formatter.shellcheck.priority = 1;
                formatter.shfmt.priority = 2;
                formatter.nixfmt.options = [
                  "-w"
                  "80"
                ];
                global.excludes = [
                  ".editorconfig"
                  "LICENSE"
                  "dotfiles/*"
                  "*/LICENSE"
                  "*/justfile"
                  "*.adoc"
                  "*.kdl"
                  "*.mustache"
                  "*.zsh"
                  "*rc"
                ];
              };
            };
          };

        flake = {
          overlays.default =
            _: prev:
            (
              if (builtins.hasAttr prev.stdenv.system self.packages) then
                (builtins.mapAttrs (_: drv: drv)
                  # 다음 방법을 사용하면 packages 를 선언하는 `pkgs` 는 `allowUnfree` 가 되어야한다.
                  # 다만, overlays 단에서 unfree 를 필터링함으로, 의도하지 않은 unfree 패키지가 설치될 일은 없을것으로 기대된다.
                  (
                    prev.lib.filterAttrs (
                      _: drv: (prev.config.allowUnfree || (!drv.meta.unfree))
                    ) self.packages.${prev.stdenv.system}
                  )
                )
              else
                { }
            );
        };
      };
}
