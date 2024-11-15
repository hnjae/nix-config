{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;

    specialArgs = {inherit inputs self;};
  in {
    vm = nixosSystem {
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
          generic-nixos.role = "vm";
        }
      ];
    };

    hypervisor = nixosSystem {
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
          generic-nixos.role = "hypervisor";
        }
      ];
    };

    dekstop = nixosSystem {
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
          generic-nixos.role = "desktop";
        }
      ];
    };
  };
}
