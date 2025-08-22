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
          };
        }
      )
      "${self}/modules/profiles/base-nixos/core/keyboard.nix"
      "${self}/modules/profiles/base-nixos/packages"
      (
        { lib, ... }:
        {
          isoImage = {
            squashfsCompression = "zstd -Xcompression-level 4";
            makeBiosBootable = false;
          };

          systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
          users.users.root = {
            openssh.authorizedKeys.keys = [
              self.shared.keys.ssh.home
            ];
            initialHashedPassword = lib.mkForce "$y$j9T$HNGnCeOFmjNWzc5K7Dnh51$QNWhudURk9C/iJ/KOhJAjHRj3aadSROs50wO/SqaoED"; # nixos
          };
          users.users.nixos = {
            openssh.authorizedKeys.keys = [
              self.shared.keys.ssh.home
            ];
            # default: no password
            initialHashedPassword = lib.mkForce "$y$j9T$HNGnCeOFmjNWzc5K7Dnh51$QNWhudURk9C/iJ/KOhJAjHRj3aadSROs50wO/SqaoED";
          };

          nixpkgs.overlays = [
            self.overlays.default
          ];

          nixpkgs.config.allowUnfree = true;
          systemd.sleep.extraConfig = ''
            AllowSuspend=no
            AllowHibernation=no
            AllowSuspendThenHibernate=no
            AllowHybridSleep=no
          '';
        }
      )
    ];
  };
}
