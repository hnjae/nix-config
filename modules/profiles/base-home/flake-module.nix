flakeArgs@{
  flake-parts-lib,
  inputs,
  self,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
in
{
  flake.homeManagerModules.base-home = {
    imports = [
      ./.
      inputs.base16.homeManagerModule
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
      inputs.nix-index-database.hmModules.nix-index
      inputs.nix-web-app.homeManagerModules.default
      (importApply ./with-import-apply/base24 { inherit inputs; })

      (
        { pkgs, ... }:
        {
          _module.args = {
            pkgsUnstable = import flakeArgs.inputs.nixpkgs-unstable {
              inherit (pkgs.stdenv) system;
              config = {
                inherit (pkgs.config) allowUnfree;
              };
              overlays = [
                (_: prev: {
                  ghostty-tip = inputs.ghostty.packages.${prev.system}.default;
                })
              ];
            };
          };
        }
      )
      {
        # NOTE: HomeManager 가 NixOS 모듈로 사용되고, useGlobalPackages 가 설정되어 있으면 아래 값은 무시된다. <2025-02-06>
        nixpkgs.overlays = [
          self.overlays.default
        ];
      }
    ];
  };
}
