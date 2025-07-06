{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  package = ((import ./package) { inherit pkgs pkgsUnstable; });
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
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

    # xdg.mimeApps.associations.removed =
    #   let
    #     desktopName = "YACReader.desktop";
    #     mimeTypes = [
    #       "application/x-zip"
    #       "application/x-rar"
    #       "application/x-7z"
    #       "inode/directory"
    #     ];
    #   in
    #   (builtins.listToAttrs (
    #     builtins.map (mimeType: {
    #       name = mimeType;
    #       value = desktopName;
    #     }) mimeTypes
    #   ));
  };
}
