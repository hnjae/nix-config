flakeArgs@{
  inputs,
  ...
}:
{
  flake.homeManagerModules.base-home = {
    imports = [
      (
        {
          lib,
          ...
        }:
        let
          moduleName = "base-home";
        in
        {
          options.${moduleName} =
            let
              inherit (lib) mkOption types;
            in
            {
              isDesktop = mkOption {
                type = types.bool;
                default = false;
                description = "Is this a desktop system with GUI enabled?";
              };
              isDev = mkOption {
                type = types.bool;
                default = false;
                description = "Should I install development tools?";
              };
              isHome = mkOption {
                type = types.bool;
                default = false;
              };
            };
        }
      )

      ./config
      ./modules
      ./programs
      ./services
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
      inputs.nix-web-app.homeManagerModules.default
      inputs.nix-index-database.homeModules.nix-index
      {
        programs.nix-index-database.comma.enable = true;
      }

      (
        { pkgs, ... }:
        {
          _module.args = {
            pkgsUnstable = import flakeArgs.inputs.nixpkgs-unstable {
              inherit (pkgs) system;
              config = {
                inherit (pkgs.config) allowUnfree;
              };
            };
          };
        }
      )
      {
        # NOTE: HomeManager 가 NixOS 모듈로 사용되고, useGlobalPackages 가 설정되어 있으면 아래 값은 무시된다. <2025-02-06>
        # FIXME: 아래 값은 homeManager 가 NixOS 모듈로 사용될 때, 허용되지 않게 됨. <HomeManager 25.05>
        # nixpkgs.overlays = [
        #   self.overlays.default
        #   inputs.rust-overlay.overlays.default
        # ];
      }
    ];
  };
}
