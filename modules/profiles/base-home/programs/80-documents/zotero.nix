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

    # home.packages = [ pkgsUnstable.zotero_7 ];
    #
    # xdg.desktopEntries."zotero" = {
    #   # GenericName=Reference Management
    #   name = "Zotero";
    #   comment = "with custom desktop entry";
    #   exec = "env MOZ_ENABLE_WAYLAND=1 zotero -url %U";
    #   terminal = false;
    #   icon = "zotero";
    #   type = "Application";
    #   startupNotify = true;
    #   categories = [
    #     "Office"
    #     "Database"
    #   ];
    #   mimeType = [
    #     "x-scheme-handler/zotero"
    #     "text/plain"
    #   ];
    # };
  };
}
