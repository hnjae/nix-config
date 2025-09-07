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
    (lib.lists.optionals (baseHomeCfg.isDesktop) [
      pkgs.zathura
      (lib.hiPrio (
        pkgs.runCommandLocal "zathura-icon-fix" { } ''
          mkdir -p "$out/share/icons/hicolor/scalable/apps/"

          icon='${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/org.pwmt.zathura.svg'
          app_id='org.pwmt.zathura'

          cp --reflink=auto \
            "$icon" \
            "$out/share/icons/hicolor/scalable/apps/''${app_id}.svg"

          for size in 16 22 24 32 48 64 96 128 256 512; do
            mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps/"
            '${pkgs.librsvg}/bin/rsvg-convert' \
              --keep-aspect-ratio \
              --height="$size" \
              --output="$out/share/icons/hicolor/''${size}x''${size}/apps/''${app_id}.png" \
              "$icon"
          done
        ''
      ))
    ])
    (lib.lists.optionals (baseHomeCfg.isDev) ([
      pkgsUnstable.ocrmypdf
      pkgsUnstable.img2pdf
    ]))
  ];
}
