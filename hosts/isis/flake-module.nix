{ self, inputs, ... }:
{
  flake.nixosConfigurations.isis = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        system.stateVersion = "24.11";

        base-nixos = {
          role = "desktop";
          hostType = "baremetal";
        };

        networking.hostName = "isis";

        rollback-zfs-root = {
          enable = true;
          rollbackDataset = "isis/local/root@blank";
        };

        persist = {
          enable = true;
          isDesktop = true;
        };
      }

      self.nixosModules.base-nixos
      self.nixosModules.kde

      inputs.lanzaboote.nixosModules.lanzaboote
      self.nixosModules.rollback-zfs-root
      self.nixosModules.configure-impermanence
      inputs.quadlet-nix.nixosModules.quadlet

      ./configs
      ./hardware
      ./services
    ];

    specialArgs = {
      inherit inputs;
      inherit self;
    };
  };
}
