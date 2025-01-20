{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;

    specialArgs = {
      inherit inputs self;
      # extraConfig = {};
    };
  in {
    sample = nixosSystem {
      inherit specialArgs;
      modules = [
        {
          fileSystems."/".label = "random-tpgoH82DRzMqEqAUZ5bGxXtcOId0zvT6";
          boot.loader.systemd-boot.enable = true;
          system.stateVersion = "24.05";
          nixpkgs = {
            config.allowUnfree = true;
            hostPlatform = "x86_64-linux";
            overlays = [
              self.overlays.default
            ];
          };
        }
      ];
    };

    isis = nixosSystem {
      modules = [
        ./isis

        self.nixosModules.generic-nixos
        self.nixosModules._generic-nixos-deps
        self.nixosModules._configure-generic-home-for-nixos

        self.nixosModules.gnome

        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nix-modules-private.nixosModules.generic-nixos-extend
        self.nixosModules.rollback-zfs-root

        inputs.sops-nix.nixosModules.sops
        inputs.nix-modules-private.nixosModules.configure-sops

        inputs.impermanence.nixosModules.impermanence
        self.nixosModules.configure-impermanence
      ];
      inherit specialArgs;
    };
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
