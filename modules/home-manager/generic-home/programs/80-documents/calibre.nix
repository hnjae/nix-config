{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
  desktopEntry = {
    type = "Application";
    name = "E-book editor";
    comment = "this should not be displayed";
    exec = ":";
    noDisplay = true;
  };
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
    services.flatpak.packages =
      lib.mkIf (pkgs.stdenv.isLinux) ["com.calibre_ebook.calibre"];

    xdg.desktopEntries."com.calibre_ebook.calibre.ebook-edit" =
      lib.mkIf (pkgs.stdenv.isLinux) desktopEntry;

    xdg.desktopEntries."com.calibre_ebook.calibre.ebook-viewer" =
      lib.mkIf (pkgs.stdenv.isLinux) desktopEntry;

    xdg.desktopEntries."com.calibre_ebook.calibre.lrfviewer" =
      lib.mkIf (pkgs.stdenv.isLinux) desktopEntry;
  };
}
