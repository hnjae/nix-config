# https://nix.dev/tutorials/nixos/building-bootable-iso-image
# https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
{ self, inputs, ... }:
{
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Provide an initial copy of the NixOS channel so that the user
      # doesn't need to run "nix-channel --update" first.
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"

      # Environment
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
      (
        { lib, ... }:
        {
          boot.plymouth.enable = lib.mkForce false;
          programs = {
            evince.enable = false;
            geary.enable = false;
            evolution.enable = false;
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
          users.users.root.openssh.authorizedKeys.keys = [
            self.constants.homeSshPublic
          ];

          nixpkgs.overlays = [
            self.overlays.default
          ];

          nixpkgs.config.allowUnfree = true;
        }
      )
    ];
  };
}
