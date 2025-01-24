{ self, inputs, ... }:
{
  flake.homeConfigurations.osiris =
    let
      system = inputs.flake-utils.lib.system.x86_64-linux;
      allowUnfree = true;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = allowUnfree;
        overlays = [
          self.overlays.default
        ];
      };
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
}
