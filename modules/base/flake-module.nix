# NOTE: nixosModules/homeManagerModules 에서 self, inputs 를 쓰면, 외부 리포지토리에서는 이 모듈을 정상적으로 사용할 수 없지만 flake-module.nix 에서는 다르다. eval 하는 시점이 다르기 때문.
flakeArgs@{
  inputs,
  self,
  ...
}:
{
  flake = {
    homeManagerModules.base-home = {
      imports = [
        ./homeManagerModule
        inputs.base16.homeManagerModule
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.nix-index-database.hmModules.nix-index
        inputs.nix-web-app.homeManagerModules.default
        (
          { pkgs, ... }:
          {
            _module.args = {
              pkgsUnstable = import flakeArgs.inputs.nixpkgs-unstable {
                inherit (pkgs.stdenv) system;
                config = {
                  inherit (pkgs.config) allowUnfree;
                };
                overlays = [ ];
              };
            };
          }
        )
        {
          nixpkgs.overlays = [ self.overlays.default ];
        }
      ];
    };

    nixosModules.base-nixos = {
      imports = [
        ./nixosModule
        self.nixosModules.nix-gc-system-generations
        self.nixosModules.nix-store-gc
        inputs.home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            flakeArgs.self.overlays.default
          ];
          nixpkgs.config.allowUnfree = true;
        }
        (
          {
            lib,
            config,
            ...
          }:
          {
            # for nix shell nixpkgs#foo
            # run `nix registry list` to list current registry
            nix.registry = {
              nixpkgs-unstable = {
                flake = flakeArgs.inputs.nixpkgs-unstable;
                to = {
                  path = "${flakeArgs.inputs.nixpkgs-unstable}";
                  type = "path";
                };
              };
              nixpkgs = {
                flake = flakeArgs.inputs.nixpkgs;
                to = {
                  path = "${flakeArgs.inputs.nixpkgs}";
                  type = "path";
                };
              };
            };

            # to use nix-shell, run `nix repl :l <nixpkgs>`
            nix.channel.enable = true;
            nix.nixPath = lib.lists.optionals config.nix.channel.enable [
              "nixpkgs=${flakeArgs.inputs.nixpkgs}"
              "nixpkgs-unstable=${flakeArgs.inputs.nixpkgs-unstable}"
              # "/nix/var/nix/profiles/per-user/root/channels"
            ];
          }
        )
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = false;
            backupFileExtension = "backup";
            sharedModules = [
              self.homeManagerModules.base-home
            ];
            extraSpecialArgs = { };
          };
        }
      ];
    };
  };
}
