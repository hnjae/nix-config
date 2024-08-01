{
  self,
  inputs,
  withSystem,
  ...
}: let
  eachSystem = systems: module: (inputs.nixpkgs.lib.attrsets.mergeAttrsList (
    map (system: withSystem system module) systems
  ));
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
    };
  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  commonModules = [
    {
      home = rec {
        username = "sample-iYlnUryoqG94MVgv";
        homeDirectory = "/home/${username}";
        stateVersion = "24.05";
      };
    }
    self.homeManagerModules.default
  ];
in {
  flake.homeConfigurations = inputs.nixpkgs.lib.attrsets.mergeAttrsList [
    (eachSystem (with inputs.flake-utils.lib.system; [
        x86_64-linux
        aarch64-darwin
      ]) ({
        pkgs,
        system,
        ...
      }: {
        "shell-${system}" = homeManagerConfiguration {
          inherit pkgs;
          modules = builtins.concatLists [
            commonModules
            [
              {
                generic-home = {
                  isDesktop = false;
                  base24 = {
                    enable = false;
                  };
                  installDevPackages = true;
                  installTestApps = false;
                };
              }
            ]
          ];
          extraSpecialArgs = {
            inherit inputs;
            pkgsUnstable = getPkgsUnstable system pkgs.config.allowUnfree;
          };
        };

        "desktop-${system}" = homeManagerConfiguration {
          inherit pkgs;
          modules = builtins.concatLists [
            commonModules
            [
              {
                generic-home = {
                  isDesktop = true;
                  base24 = {
                    enable = true;
                    scheme = "kanagawa";
                    darkMode = false;
                  };
                  installDevPackages = true;
                  installTestApps = true;
                };
              }
            ]
          ];
          extraSpecialArgs = {
            inherit inputs;
            pkgsUnstable = getPkgsUnstable system pkgs.config.allowUnfree;
          };
        };
      }))
    (eachSystem (with inputs.flake-utils.lib.system; [
        x86_64-linux
      ]) ({system, ...}: let
        allowUnfree = true;
      in {
        "desktop-plasma6-unfree-${system}" = homeManagerConfiguration rec {
          pkgs = getPkgs system allowUnfree;
          modules = builtins.concatLists [
            commonModules
            [
              self.homeManagerModules.de-plasma6
              {
                generic-home = {
                  isDesktop = true;
                  base24 = {
                    enable = true;
                    scheme = "kanagawa";
                    darkMode = false;
                  };
                  installDevPackages = true;
                  installTestApps = true;
                };
              }
            ]
          ];
          extraSpecialArgs = {
            inherit inputs;
            pkgsUnstable = getPkgsUnstable system pkgs.config.allowUnfree;
          };
        };
      }))
  ];
}
