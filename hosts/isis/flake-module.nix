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
      }

      self.nixosModules.base-nixos
      self.nixosModules.kde

      inputs.impermanence.nixosModules.impermanence
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.quadlet-nix.nixosModules.quadlet

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
