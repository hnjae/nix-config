{ self, inputs, ... }:
{
  flake.nixosConfigurations.isis = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        imports = [
          ./configs
          ./hardware
          ./services
        ];
        system.stateVersion = "24.11";
        base-nixos.role = "desktop";

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
      self.nixosModules.gnome

      inputs.lanzaboote.nixosModules.lanzaboote
      self.nixosModules.rollback-zfs-root

      self.nixosModules.configure-impermanence
      self.nixosModules.syncthing-for-desktop
    ];
    specialArgs = { inherit inputs; };
  };
}
