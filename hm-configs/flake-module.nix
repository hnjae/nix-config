{
  self,
  inputs,
  ...
}: let
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
  flake.homeConfigurations = {
    "osiris" = let
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
          self.homeManagerModules.default
          {
            generic-home = {
              isDesktop = true;
              base24 = {
                enable = true;
                scheme = "kanagawa";
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
  };
}
