{
  description = "my nix-config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs = {nixpkgs-lib.follows = "nixpkgs";};
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
        pre-commit-hooks-nix.follows = "";
        # flake-compat.follows = "nix-config/flake-compat";
        rust-overlay.follows = "rust-overlay";
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
    ghostty = {
      url = "github:ghostty-org/ghostty/refs/tags/tip";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.zig.follows = "";
      inputs.flake-compat.follows = "";
    };
    nixpkgs-mozilla.url = "github:mozilla/nixpkgs-mozilla";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-parts.follows = "flake-parts";
        nix-darwin.follows = "";
        git-hooks.follows = "";
        devshell.follows = "";
        treefmt-nix.follows = "";
        nuschtosSearch.follows = "";
      };
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
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
    # to fix duplicate dependencies
    ############################################################################
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    flake-utils,
    base16,
    ...
  }:
    flake-parts.lib.mkFlake {
      inherit inputs;
      # inherit base16;
    } {
      imports = [
        ./flake-output-attributes

        ./apps/flake-module.nix
        ./packages/flake-module.nix

        ./hosts/flake-module.nix

        ./modules/gnome/flake-module.nix
        ./modules/generic/flake-module.nix
        ./modules/nixosModules/flake-module.nix
      ];
      systems = with flake-utils.lib.system; [
        x86_64-linux
        aarch64-darwin
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
        # https://nix.dev/tutorials/nixos/building-bootable-iso-image
        # https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
        nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            {
              programs = {
                geary.enable = false;
                evolution.enable = false;
              };
              # environment.gnome.excludePackages = with ?; [
              #   gnome-tour
              #   gnome-shell-extensions
              #   gnome-calendar
              #   gnome-contacts
              #   gnome-weather
              #   gnome-clocks
              #   gnome-font-viewer
              # ];
            }
            {
              isoImage = {
                squashfsCompression = "zstd -Xcompression-level 6";
                makeBiosBootable = false;
              };
            }
            {
              systemd.services.sshd.wantedBy = nixpkgs.lib.mkForce ["multi-user.target"];
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJzpwZFnwPxTF4TU7IX5AI+Nwpu9VvjI4A9Jlh3P0pu"
              ];
            }
            {
              services.xserver.xkb = {
                layout = "us";
                variant = "colemak_dh";
                options = builtins.concatStringsSep "," [
                  # "shift:both_capslock_cancel"
                  "altwin:swap_lalt_lwin"
                  "korean:ralt_hangul"
                  "caps:backspace"
                ];
              };
            }
            "${self}/modules/nixos/generic-nixos/packages"
            {
              nixpkgs.overlays = [
                self.overlays.default
              ];
            }
          ];
        };
        overlays.default = _: prev: (
          if (builtins.hasAttr prev.stdenv.system self.packages)
          then
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
