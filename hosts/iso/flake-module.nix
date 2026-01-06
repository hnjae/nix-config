# https://nix.dev/tutorials/nixos/building-bootable-iso-image
# https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
{
  self,
  inputs,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
  flakeArgs = {
    localFlake = self;
    inherit flake-parts-lib;
    inherit importApply;
    inherit inputs;
  };
in
{
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Environment
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
      (
        {
          lib,
          ...
        }:
        {
          boot.plymouth.enable = lib.mkForce false;
          programs = {
            evince.enable = false;
            geary.enable = false;
            evolution.enable = false;

            vim.enable = false;
            nano.enable = false;
            neovim.enable = false;
            zsh.enable = true;
          };
        }
      )
      "${self}/profiles/base-nixos/core/keyboard.nix"
      (importApply "${self}/profiles/base-nixos/config/nix.nix" flakeArgs)
      (
        { lib, pkgs, ... }:
        {
          isoImage = {
            squashfsCompression = "zstd -Xcompression-level 11";
            makeBiosBootable = false;
          };

          systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

          users = {
            defaultUserShell = pkgs.bash;

            users.root = {
              openssh.authorizedKeys.keys = [
                self.shared.keys.ssh.home
              ];
              initialHashedPassword = lib.mkForce "$y$j9T$HNGnCeOFmjNWzc5K7Dnh51$QNWhudURk9C/iJ/KOhJAjHRj3aadSROs50wO/SqaoED"; # nixos
            };

            users.nixos = {
              openssh.authorizedKeys.keys = [
                self.shared.keys.ssh.home
              ];
              # default: no password
              initialHashedPassword = lib.mkForce "$y$j9T$HNGnCeOFmjNWzc5K7Dnh51$QNWhudURk9C/iJ/KOhJAjHRj3aadSROs50wO/SqaoED";
            };
          };

          systemd.sleep.extraConfig = ''
            AllowSuspend=no
            AllowHibernation=no
            AllowSuspendThenHibernate=no
            AllowHybridSleep=no
          '';

          nixpkgs = {
            overlays = [
              self.overlays.default
              self.overlays.unstable
            ];
            config.allowUnfree = true;
          };

          # nix = {
          #   settings = {
          #     experimental-features = [
          #       "nix-command"
          #       "flakes"
          #     ];
          #   };
          #   max-jobs = 4; # max concurrent build
          #   registry = {
          #     nixpkgs = {
          #       flake = inputs.nixpkgs;
          #       to = {
          #         path = "${inputs.nixpkgs}";
          #         type = "path";
          #       };
          #     };
          #     nixpkgs-unstable = {
          #       flake = inputs.nixpkgs-unstable;
          #       to = {
          #         path = "${inputs.nixpkgs-unstable}";
          #         type = "path";
          #       };
          #     };
          #     nix-config = {
          #       flake = self;
          #       to = {
          #         path = "${self}";
          #         type = "path";
          #       };
          #     };
          #   };
          # };
          #
          # channel.enable = true;
          # nixPath = [
          #   "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
          #   "nixpkgs=${inputs.nixpkgs}"
          #   "nix-config=${self}"
          # ];

          environment.systemPackages = lib.flatten [
            (self.packageSets.system pkgs)
            (self.packageSets.user pkgs)
            (self.packageSets.user-home pkgs)
          ];
        }
      )
    ];
  };
}
