{
  self,
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  getPkgs =
    system: allowUnfree:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = allowUnfree;
      overlays = [
        self.overlays.default
      ];
    };

  inherit (inputs.home-manager.lib) homeManagerConfiguration;
in
{
  flake.homeConfigurations.osiris =
    let
      system = inputs.flake-utils.lib.system.x86_64-linux;
      allowUnfree = true;
    in
    homeManagerConfiguration rec {
      pkgs = getPkgs system allowUnfree;
      modules = [
        {
          home = {
            username = "hnjae";
            homeDirectory = "/home/hnjae";
            stateVersion = "24.11";
          };
        }
        self.homeManagerModules.base-home
        {
          base-home = {
            isDesktop = true;
            base24 = {
              enable = true;
              darkMode = false;
            };
            installDevPackages = true;
            installTestApps = false;
          };
          stateful.enable = false;
        }
      ];
      extraSpecialArgs = { };
    };

  flake.nixosConfigurations.sample = nixosSystem {
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

  flake.nixosConfigurations.isis = nixosSystem {
    modules = [
      self.nixosModules.base-nixos
      inputs.nix-modules-private.nixosModules.base-nixos-extend
      self.nixosModules.gnome

      ./isis
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
