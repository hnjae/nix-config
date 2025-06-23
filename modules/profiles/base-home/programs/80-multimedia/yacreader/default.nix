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
    home.packages = [ ((import ./package) { inherit pkgs pkgsUnstable; }) ];

    default-app.mime = {
      "application/vnd.comicbook+zip" = "YACReader";
      "application/vnd.comicbook-rar" = "YACReader";
      "application/x-cb7" = "YACReader";
      "application/x-cbt" = "YACReader";
    };

    xdg.dataFile =
      let
        desktops = [
          "YACReaderLibrary.desktop"
        ];

        desktopEntryText = ''
          [Desktop Entry]
          NoDisplay=true
          Exec=:
          Name=This should not be displayed
          Type=Application
        '';
      in
      (builtins.listToAttrs (
        builtins.map (desktop: {
          name = "applications/${desktop}";
          value = {
            text = desktopEntryText;
          };
        }) desktops
      ));
  };
}
