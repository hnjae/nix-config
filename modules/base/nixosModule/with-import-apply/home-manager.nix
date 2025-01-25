{ localFlake, ... }:
{ config, ... }:
let
  cfg = config.base-nixos;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
    backupFileExtension = "backup";
    sharedModules = [
      localFlake.homeManagerModules.base-home
    ];
    extraSpecialArgs = { };
    users.hnjae = _: {
      home.stateVersion = "24.05";
      base-home = {
        isDesktop = cfg.role == "desktop";
        isDev = cfg.role == "desktop";
        isHome = true;
      };
      stateful.enable = cfg.role == "desktop";
    };
  };
}
