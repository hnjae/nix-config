{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    home.packages = [
      ((import ./package) { inherit pkgs pkgsUnstable; })
      (lib.hiPrio (
        pkgs.makeDesktopItem {
          name = "YACReaderLibrary.desktop";
          desktopName = "This should not be displayed.";
          exec = ":";
          noDisplay = true;
        }
      ))
    ];

    default-app.mime = {
      "application/vnd.comicbook+zip" = "YACReader";
      "application/vnd.comicbook-rar" = "YACReader";
      "application/x-cb7" = "YACReader";
      "application/x-cbt" = "YACReader";
    };
  };
}
