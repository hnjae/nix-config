{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    home.packages = [pkgsUnstable.zotero_7];

    xdg.desktopEntries."zotero" = {
      # GenericName=Reference Management
      name = "Zotero";
      comment = "with custom desktop entry";
      exec = "env MOZ_ENABLE_WAYLAND=1 zotero -url %U";
      terminal = false;
      icon = "zotero";
      type = "Application";
      startupNotify = true;
      categories = ["Office" "Database"];
      mimeType = ["x-scheme-handler/zotero" "text/plain"];
    };

    stateful.nodes = [
      {
        path = "${config.home.homeDirectory}/.zotero";
        mode = "755";
        type = "dir";
      }
    ];
  };
}
