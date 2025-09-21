# https://nix.dev/tutorials/nixos/building-bootable-iso-image
# https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
{
  self,
  inputs,
  ...
}:
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
      "${self}/modules/profiles/base-nixos/core/keyboard.nix"
      # "${self}/modules/profiles/base-nixos/packages"
      (
        { lib, pkgs, ... }:
        {
          isoImage = {
            squashfsCompression = "zstd -Xcompression-level 4";
            makeBiosBootable = false;
          };

          systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

          users = {
            defaultUserShell = pkgs.zsh;

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
