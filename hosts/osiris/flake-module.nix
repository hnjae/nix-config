{ self, inputs, ... }:
{
  flake.nixosConfigurations.osiris = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.quadlet-nix.nixosModules.quadlet

      self.nixosModules.base-nixos
      self.nixosModules.configure-impermanence
      self.nixosModules.kde
      self.nixosModules.rollback-zfs-root

      {
        system.stateVersion = "25.05";

        base-nixos = {
          role = "desktop";
          hostType = "baremetal";
        };

        networking.hostName = "osiris";

        rollback-zfs-root = {
          enable = true;
          rollbackDataset = "osiris/local/rootfs@blank";
        };

        persist = {
          enable = true;
          isDesktop = true;
        };
      }

      ./config
      ./hardware
      ./services
    ];

    specialArgs = {
      inherit inputs;
      inherit self;
    };
  };
}
