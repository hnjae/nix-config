{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.lists)
    optionals
    ;
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && baseHomeCfg.isHome) {
    services.flatpak.packages = [
      "com.valvesoftware.Steam"
    ];
    services.flatpak.overrides."com.valvesoftware.Steam" = {
      Context = {
        filesystems = [
          "/steam"
        ];
      };
    };

    home.packages = builtins.concatLists [
      (optionals pkgs.stdenv.isLinux (
        with pkgs;
        [
          # others
          gamescope
        ]
      ))
    ];
  };
}
