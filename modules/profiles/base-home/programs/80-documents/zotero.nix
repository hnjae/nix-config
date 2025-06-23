{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  appId = "org.zotero.Zotero";
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && baseHomeCfg.isHome && pkgs.stdenv.isLinux) {
    services.flatpak.packages = [ appId ];

    services.flatpak.overrides."${appId}" = {
      Context = {
        filesystems = [ "!home" ];
      };
    };
  };
}
