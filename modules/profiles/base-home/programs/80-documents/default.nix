{
  pkgs,
  pkgsUnstable,
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  imports = [
    ./50-editors

    ./calibre.nix
    ./latex.nix
    ./libreoffice.nix
    ./logseq.nix
    ./obsidian
    ./onlyoffice.nix
    ./typst.nix
    ./zotero.nix
  ];

  default-app.mime."application/pdf" = "org.gnome.Papers";
  services.flatpak.packages = [
    "com.github.johnfactotum.Foliate"
    "com.github.jeromerobert.pdfarranger"
    "com.github.ahrm.sioyek" # pdfviewer
    "org.gnome.Papers"
  ];
  home.packages = lib.flatten [
    (lib.lists.optional (baseHomeCfg.isDesktop) pkgs.zathura)
    (lib.lists.optionals (baseHomeCfg.isDev) ([
      pkgsUnstable.ocrmypdf
      pkgsUnstable.img2pdf
    ]))
  ];
}
