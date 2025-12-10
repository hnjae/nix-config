{
  self,
  inputs,
  ...
}:
{
  # flake.deploy.nodes.osiris = {
  #   hostname = "osiris";
  #   profiles.system = {
  #     sshUser = "deploy";
  #     user = "root";
  #     path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.osiris;
  #   };
  # };

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
