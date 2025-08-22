{ self, inputs, ... }:
{
  flake.nixosConfigurations.eris = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.quadlet-nix.nixosModules.quadlet

      self.nixosModules.base-nixos

      {
        system.stateVersion = "25.05";
        networking.hostName = "eris";

        base-nixos = {
          role = "none";
          hostType = "baremetal";
        };
      }

      ./config
      ./hardware
      # ./services
    ];

    specialArgs = {
      inherit inputs;
      inherit self;
    };
  };
}
