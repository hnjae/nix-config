/*
NOTE: nixosModules/homeManagerModules 에서 self, inputs 를 쓰면, 외부 리포지토리에서는 이 모듈을 정상적으로 사용할 수 없지만 flake-module.nix 에서는 다르다. eval 하는 시점이 다르기 때문.
*/
{inputs, ...}: {
  flake = rec {
    homeManagerModules.generic-home = {
      imports = [
        (import ./homeManagerModule)
        inputs.base16.homeManagerModule
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.nix-index-database.hmModules.nix-index
        inputs.nix-web-app.homeManagerModules.default
      ];
    };

    nixosModules.generic-nixos = {
      imports = [
        (import ./nixosModule)
        (import ../nixosModules/services/nix-gc-system-generations)
        (import ../nixosModules/services/nix-store-gc)
        inputs.home-manager.nixosModules.home-manager
        (
          {
            pkgs,
            self,
            inputs,
            config,
            ...
          }: {
            config = {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = false;
                backupFileExtension = "backup";
                sharedModules = [
                  homeManagerModules.generic-home
                  {
                    nixpkgs.overlays = [self.overlays.default];
                  }
                ];

                extraSpecialArgs = {
                  inherit inputs self;
                  pkgsUnstable = import inputs.nixpkgs-unstable {
                    inherit (pkgs.stdenv) system;
                    config.allowUnfree = pkgs.config.allowUnfree;
                    overlays = [];
                  };
                };
              };
            };
          }
        )
      ];
    };
  };
}
