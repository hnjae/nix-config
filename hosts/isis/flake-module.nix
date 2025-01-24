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
      inputs.nix-modules-private.nixosModules.base-nixos-extend
      self.nixosModules.gnome

      inputs.lanzaboote.nixosModules.lanzaboote
      self.nixosModules.rollback-zfs-root

      inputs.nix-modules-private.nixosModules.configure-sops
      self.nixosModules.configure-impermanence
      self.nixosModules.syncthing-for-desktop
    ];
    specialArgs = { inherit inputs; };
  };
  # flake.deploy.nodes.isis = {
  #   hostname = "isis";
  #   profiles.system = {
  #     user = "nix-ssh";
  #     path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.isis;
  #   };
  # };
  #
  # flake.checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
}
