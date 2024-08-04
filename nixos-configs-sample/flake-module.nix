{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;

    specialArgs = {inherit inputs self;};
  in {
    generic = nixosSystem {
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
        self.nixosModules.default
      ];
    };

    generic-dekstop = nixosSystem {
      inherit specialArgs;
      modules = [
        {
          fileSystems."/".label = "random-tpgoH82DRzMqEqAUZ5bGxXtcOId0zvT6";
          boot.loader.systemd-boot.enable = true;
          system.stateVersion = "24.05";
          nixpkgs = {
            config.allowUnfree = false;
            hostPlatform = "x86_64-linux";
            overlays = [
              self.overlays.default
            ];
          };
        }
        self.nixosModules.default
        {
          generic-nixos.isDesktop = true;
        }
      ];
    };

    generic-dekstop-plasma6 = nixosSystem {
      inherit specialArgs;
      modules = [
        {
          fileSystems."/".label = "random-tpgoH82DRzMqEqAUZ5bGxXtcOId0zvT6";
          boot.loader.systemd-boot.enable = true;
          system.stateVersion = "24.05";
          nixpkgs = {
            config.allowUnfree = false;
            hostPlatform = "x86_64-linux";
            overlays = [
              self.overlays.default
            ];
          };
        }
        self.nixosModules.default
        {
          generic-nixos.isDesktop = true;
        }
        self.nixosModules.de-plasma6
      ];
    };

    generic-dekstop-plasma6-unfree = nixosSystem {
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
        self.nixosModules.default
        {
          generic-nixos.isDesktop = true;
        }
        self.nixosModules.de-plasma6
      ];
    };
  };
}
