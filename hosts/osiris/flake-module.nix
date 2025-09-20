{ self, inputs, ... }:
{
  flake.nixosConfigurations.osiris = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.quadlet-nix.nixosModules.quadlet

      self.nixosModules.base-nixos
      self.nixosModules.kde
      {
        system.stateVersion = "25.05";
        networking.hostName = "osiris";

        base-nixos = {
          role = "desktop";
          hostType = "baremetal";
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
