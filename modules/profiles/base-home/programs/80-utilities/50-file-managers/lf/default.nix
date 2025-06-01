{
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
{
  home.packages = [
    pkgsUnstable.lf
    pkgsUnstable.chafa
    pkgsUnstable.imagemagick
    (pkgs.runCommandLocal "papers-thumbnailer" { } ''
      mkdir -p "$out/bin"
      ln -s "${pkgs.papers}/bin/papers-thumbnailer" "$out/bin/papers-thumbnailer"
    '')
    pkgs.epub-thumbnailer
    pkgs.gnome-epub-thumbnailer # for epub & mobi
  ];

  xdg.configFile."lf/icons" = {
    # podman config
    text =
      let
        icons = (import ./resources/icons);
      in
      lib.concatLines (
        builtins.concatLists [
          (lib.mapAttrsToList (key: icon: "${key}\t${icon}") icons.lfIconTypes)
          (lib.mapAttrsToList (key: icon: "*${key}\t${icon}") icons.directoryIcons)
          (lib.mapAttrsToList (key: icon: "*${key}\t${icon}") icons.filenameIcons)
          (lib.mapAttrsToList (key: icon: "*.${key}\t${icon}") icons.extensionIcons)
        ]
      );
  };
}
