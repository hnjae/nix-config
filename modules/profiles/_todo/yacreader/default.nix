{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (pkgs.hostPlatform) isLinux;

  package = (import ./package) { inherit pkgs pkgsUnstable; };
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && isLinux) {
    home.packages = [
      package
      (lib.hiPrio (
        pkgs.runCommandLocal "custom-desktop-entry" { } ''
          mkdir -p $out/share/applications
          substitute ${package}/share/applications/YACReader.desktop $out/share/applications/YACReader.desktop \
            --replace 'application/x-zip;application/x-rar;application/x-7z;inode/directory;' ""
        ''
      ))
      (lib.hiPrio (
        pkgs.makeDesktopItem {
          name = "YACReaderLibrary";
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
