{ self, inputs, ... }:
{
  flake.deploy.nodes.eris = {
    # hostname = "${deviceName}.local";
    hostname = "eris";
    profiles.system = {
      sshUser = "deploy";
      user = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.eris;
    };
  };

  flake.nixosConfigurations.eris = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.quadlet-nix.nixosModules.quadlet
      self.nixosModules.base-nixos

      {
        system.stateVersion = "25.05";
        networking.hostName = "eris";

        base-nixos = {
          role = "none";
          hostType = "baremetal";
        };

        nixpkgs.overlays = [
        ];
      }

      ./config
      ./hardware
      ./serve-encrypted
      ./services
    ];

    specialArgs = {
      inherit inputs;
      inherit self;
    };
  };
}
