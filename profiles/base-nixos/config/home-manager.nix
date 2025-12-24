{ ... }:
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
      {
        home.preferXdgDirectories = true;
        xdg = {
          enable = true;
          userDirs.createDirectories = cfg.role == "desktop";
        };
      }
    ];
    extraSpecialArgs = { };
    users.hnjae = _: {
      home.stateVersion = config.system.stateVersion;
    };
  };
}
