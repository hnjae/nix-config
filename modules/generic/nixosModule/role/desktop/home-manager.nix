{
  pkgs,
  self,
  inputs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf (builtins.hasAttr "home-manager" config) {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = false;
      backupFileExtension = "backup";
      sharedModules = [
        self.homeManagerModules.generic-home
        self.homeManagerModules._generic-home-deps
      ];

      extraSpecialArgs = {
        pkgsUnstable = import inputs.nixpkgs-unstable {
          inherit (pkgs.stdenv) system;
          config.allowUnfree = pkgs.config.allowUnfree;
          overlays = [
            # inputs.nur.overlays.default
            # inputs.rust-overlay.overlays.default
          ];
        };
      };
    };
  };
}
