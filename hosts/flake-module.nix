{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  getPkgsUnstable = system: allowUnfree:
    import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = allowUnfree;
      overlays = [
        inputs.rust-overlay.overlays.default
      ];
    };

  getPkgs = system: allowUnfree:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = allowUnfree;
      overlays = [
        self.overlays.default
      ];
    };

  getExtraSpecialArgs = system: allowUnfree: {
    inherit self inputs;
    pkgsUnstable = getPkgsUnstable system allowUnfree;
  };

  inherit (inputs.home-manager.lib) homeManagerConfiguration;
in {
  flake.homeConfigurations.osiris = let
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
        self.homeManagerModules.generic-home
        self.homeManagerModules._generic-home-deps
        {
          generic-home = {
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
      extraSpecialArgs = getExtraSpecialArgs system pkgs.config.allowUnfree;
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
      ./isis

      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.nix-modules-private.nixosModules.configure-sops
      inputs.nix-modules-private.nixosModules.generic-nixos-extend
      self.nixosModules.configure-impermanence
      self.nixosModules.generic-nixos
      self.nixosModules.gnome
      self.nixosModules.rollback-zfs-root
      self.nixosModules.syncthing-for-desktop
    ];
    specialArgs = {inherit inputs;};
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
