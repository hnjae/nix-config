/*
  Requires:
    * /secrets/home-age-private
    * /secrets/ssh_host_ed25519_key

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
    hostname = "${deviceName}";
    profiles.system = {
      sshUser = "deploy";
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
      (
        { ... }:
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
              authorizedKeys = [
                self.constants.homeSshPublic
              ];
              hostKeys = [
                "/secrets/ssh_host_ed25519_key"
                # config.sops.secrets.ssh-host-key-prv.path
                # "/etc/ssh/ssh_host_rsa_key"
              ];
            };
          };
        }
      )
      self.nixosModules.base-nixos
      self.nixosModules.configure-impermanence
      self.nixosModules.rollback-btrfs-root
      inputs.nix-modules-private.nixosModules.horus-services
      inputs.quadlet-nix.nixosModules.quadlet
      ./configs
      ./hardware
      ./services
      ./serve-encrypted
      ./selfhost-encrypted
    ];
    specialArgs = { inherit inputs self; };
  };
}
