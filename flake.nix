{
  description = "my nix-config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05";

      # https://hydra.nixos.org/job/nixos/release-25.05/tested#tabs-status
      # 2025-08-23 build
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
    flake-utils.url = "github:numtide/flake-utils";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };

    ############################################################################
    # nixosModules / homeManagerModule
    ############################################################################
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
    # nix-modules-private = {
    #   # url = "git+ssh://git@github.com/hnjae/nix-modules-private";
    #   # url = "git:/home/hnjae/Projects/nix-modules-private";
    #   url = "path:/home/hnjae/Projects/nix-modules-private";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     nixpkgs-unstable.follows = "nixpkgs-unstable";
    #     flake-utils.follows = "flake-utils";
    #     flake-parts.follows = "flake-parts";
    #     sops-nix.follows = "sops-nix";
    #   };
    # };
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
    xremap = {
      url = "github:xremap/nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        # devshell.follows = ""; flake.nix를 이상하게 작성했는지, devshell 이 필요하다. <2025-03-23>
        treefmt-nix.follows = "treefmt-nix"; # 상동
        home-manager.follows = "";
        hyprland.follows = "";
      };
    };

    ############################################################################
    # Overlays / Packages
    ############################################################################
    # ghostty = {
    #   url = "github:ghostty-org/ghostty/refs/tags/tip";
    #   inputs = {
    #     nixpkgs-unstable.follows = "nixpkgs-unstable";
    #     nixpkgs-stable.follows = "nixpkgs";
    #     flake-compat.follows = "";
    #   };
    # };
    # nixpkgs-mozilla.url = "github:mozilla/nixpkgs-mozilla";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nuschtosSearch.follows = "";
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    py-utils = {
      # url = "git+ssh://git@github.com/hnjae/py-utils";
      url = "path:/home/hnjae/Projects/py-utils";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "";
      };
    };
    yaml2nix = {
      url = "github:euank/yaml2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        cargo2nix.follows = "cargo2nix";
        flake-utils.follows = "flake-utils";
      };
    };

    ############################################################################
    # dev tools
    ############################################################################
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };

    ############################################################################
    # Used in input dependency only
    ############################################################################
    cargo2nix = {
      url = "github:cargo2nix/cargo2nix/release-0.11.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };

    ############################################################################
    # Misc
    ############################################################################
    # TODO: bundle some configs to nixvim <2025-03-01>
    # dotfiles = {
    #   url = "github:hnjae/dotfiles";
    #   flake = false;
    # };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      flake-utils,
      treefmt-nix,
      git-hooks,
      ...
    }:
    flake-parts.lib.mkFlake
      {
        inherit
          inputs
          ;
      }
      {
        imports = [
          git-hooks.flakeModule
          treefmt-nix.flakeModule
          # (lib.lists.optional (inputs.git-hooks ? flakeModule) inputs.git-hooks.flakeModule)
          # (lib.lists.optional (inputs.treefmt-nix ? flakeModule) inputs.treefmt-nix.flakeModule)

          ./attributes

          ./shared/flake-module.nix

          ./apps/flake-module.nix
          ./hosts/flake-module.nix
          ./packages/flake-module.nix
          ./templates/flake-module.nix

          ./modules/gnome/flake-module.nix
          ./modules/hm-modules/flake-module.nix
          ./modules/kde/flake-module.nix
          ./modules/nixos-modules/flake-module.nix
          ./modules/profiles/flake-module.nix
        ];
        systems = with flake-utils.lib.system; [
          x86_64-linux
          aarch64-darwin
        ];
        perSystem =
          {
            config,
            pkgs,
            ...
          }:
          {
            # Utilized by `nix develop`
            devShells.default = pkgs.mkShellNoCC {
              # shellHook = ''
              #   ${config.pre-commit.installationScript}
              # '';

              packages = with pkgs; [
                sops

                # LSPs / Linters / Formatters
                nil
                statix
                deadnix
                nixfmt-rfc-style

                # just
                just
                parallel
                jq
              ];
            };

            # pre-commit.settings.hooks.treefmt.enable = false;

            # Utilized by `nix fmt` (formatter)
            treefmt.config = {
              projectRootFile = "flake.nix";
              programs = {
                nixfmt = {
                  enable = true;
                  package = pkgs.nixfmt-rfc-style;
                };
                rustfmt.enable = true;
                biome.enable = true;
                fish_indent.enable = true;
                just = {
                  enable = true;
                  includes = [
                    "justfile"
                    "*/justfile"
                  ];
                };
                mdformat.enable = false; # forces indentation to 2 spaces; does not support frontmatter
                taplo.enable = true;
                ruff-format.enable = true;
                yamlfmt.enable = false;
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
                  "--width=100"
                ];
                global.excludes = [
                  # specific file name
                  ".editorconfig"
                  "*/.editorconfig"
                  ".gitattributes"
                  "*/.gitattributes"
                  "LICENSE"
                  "*/LICENSE"

                  # by directory pattern
                  "dotfiles/*"
                  "*/*-encrypted/*"
                  "*-encrypted.*"
                  "*/secrets/*"

                  # by suffix pattern
                  "*.gpg"
                  "*.adoc"
                  "*.kdl"
                  "*.mustache"
                  "*.zsh"
                  "*.txt"
                  "*.nu" # nufmt break files. don't know why. <2025-03-23>
                  "*rc"
                  "*.cheat"
                  "*.log"
                  "*.md" # mdformat does not support frontmatter, so it breaks markdown files.

                  # misc
                  "*-samples"
                ];
              };
            };
          };
      };
}
