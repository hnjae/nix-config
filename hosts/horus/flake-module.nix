/*
  Requires:
    * /perist/@/initrd-ssh-host-prviate
    * /secrets/home-age-private

  Todo:
    remove /persist/@nocow
*/
{ self, inputs, ... }:
{
  flake.nixosConfigurations.horus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.base-nixos

      self.nixosModules.configure-impermanence
      self.nixosModules.rollback-btrfs-root
      {
        system.stateVersion = "24.05";

        # base-nixos.role = "none";

        persist = {
          enable = true;
          path = "/persist/@cow";
          isDesktop = false;
        };
      }
      {
        rollback-btrfs-root = {
          enable = true;
          luksSupport = {
            enable = true;
            mappingName = "luks-horus";
            device = "/dev/disk/by-partuuid/6ae2d92d-af4e-40e3-9f93-6a3d22dd4a34";
          };
          sshLuksUnlock = {
            enable = true;
            networkKernelModule = "r8169";
            networkInterfaceName = "eno1";
            authorizedKeys = [ self.constants.homeSshPublic ];
            hostKeys = [
              "/persist/@/initrd-ssh-host-prviate"
            ];
          };
        };
      }
      ./configs
      ./hardware
    ];
    specialArgs = { inherit inputs; };
  };
}
