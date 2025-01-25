flakeArgs@{
  inputs,
  self,
  flake-parts-lib,
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
}
