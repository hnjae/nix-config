# https://nix.dev/tutorials/nixos/building-bootable-iso-image
# https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
{ self, inputs, ... }:
{
  flake.nixosConfigurations.nixos-iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
      {
        programs = {
          geary.enable = false;
          evolution.enable = false;
        };
      }
      {
        isoImage = {
          squashfsCompression = "zstd -Xcompression-level 6";
          makeBiosBootable = false;
        };
      }
      (
        { lib, ... }:
        {
          systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
          users.users.root.openssh.authorizedKeys.keys = [
            self.constants.homeSshPublic
          ];
        }
      )
      "${self}/modules/base/nixosModule/core/keyboard.nix"
      "${self}/modules/base/nixosModule/packages"
      {
        nixpkgs.overlays = [
          self.overlays.default
        ];
        nixpkgs.config.allowUnfree = true;
      }
    ];
  };
}
