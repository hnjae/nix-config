/*
  Requires:
    * /perist/@/initrd-ssh-host-prviate
    * /secrets/home-age-private

  Todo:
    remove /persist/@nocow
*/
{ self, inputs, ... }:
let
  deviceName = "horus";
in
{
  flake.deploy.nodes.${deviceName} = {
    # hostname = "${deviceName}.local";
    hostname = "192.168.0.200";
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${deviceName};
    };
  };

  flake.nixosConfigurations.${deviceName} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        system.stateVersion = "24.05";
        # base-nixos.role = "none";
        networking.hostName = deviceName;

        persist = {
          enable = true;
          path = "/persist/@cow";
          isDesktop = false;
          isRootNotZFS = true;
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
      self.nixosModules.base-nixos
      self.nixosModules.configure-impermanence
      self.nixosModules.rollback-btrfs-root
      inputs.nix-modules-private.nixosModules.horus-services
      ./configs
      ./hardware
    ];
    specialArgs = { inherit inputs self; };
  };
}
