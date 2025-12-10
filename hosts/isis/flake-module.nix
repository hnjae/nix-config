{
  self,
  inputs,
  ...
}:
{
  # flake.deploy.nodes.isis = {
  #   hostname = "isis";
  #   profiles.system = {
  #     sshUser = "deploy";
  #     user = "root";
  #     path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.isis;
  #   };
  # };

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
