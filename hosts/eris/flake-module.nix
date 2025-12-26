let
  hostName = "eris";
in
{
  inputs,
  lib,
  self,
  ...
}:
{
  flake.deploy.nodes =
    let
      fqdns = [
        hostName
        "${hostName}.local"
      ];
    in
    builtins.listToAttrs (
      map (
        fqdn:
        (lib.nameValuePair (builtins.replaceStrings [ "." ] [ "-" ] fqdn) {
          hostname = fqdn;
          profiles.system = {
            sshUser = "deploy";
            user = "root";
            path =
              inputs.deploy-rs.lib.${
                self.nixosConfigurations.${hostName}.pkgs.stdenv.hostPlatform.system
              }.activate.nixos
                self.nixosConfigurations.${hostName};
          };
        })
      ) fqdns
    );

  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.quadlet-nix.nixosModules.quadlet
      # inputs.nixvirt.nixosModules.default

      self.nixosModules.base-nixos

      {
        system.stateVersion = "25.05";
        networking.hostName = hostName;

        base-nixos = {
          role = "none";
          hostType = "baremetal";
        };

        nixpkgs.overlays = [
        ];
      }

      ./config
      ./hardware
      ./services
      ./timers

      ./serve-encrypted
    ];

    specialArgs = {
      inherit inputs;
      inherit self;
    };
  };
}
