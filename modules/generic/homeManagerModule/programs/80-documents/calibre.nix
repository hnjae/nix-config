{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop && pkgs.stdenv.isLinux) (lib.mkMerge [
    {
      services.flatpak.packages =
        lib.mkIf (pkgs.stdenv.isLinux) ["com.calibre_ebook.calibre"];
    }
    {
      xdg.dataFile = let
        desktops = [
          "com.calibre_ebook.calibre.ebook-edit.desktop"
          "com.calibre_ebook.calibre.ebook-viewer.desktop"
          "com.calibre_ebook.calibre.lrfviewer.desktop"
        ];

        desktopEntryText = ''
          [Desktop Entry]
          NoDisplay=true
          Exec=:
          Name=This should not be displayed
          Type=Application
        '';
      in (
        builtins.listToAttrs (builtins.map (desktop: {
            name = "applications/${desktop}";
            value = {text = desktopEntryText;};
          })
          desktops)
      );
    }
    {
      xdg.mimeApps.associations.removed = let
        desktopName = "com.calibre_ebook.calibre.desktop";
        mimeTypes = [
          "application/epub+zip"
          "application/ereader"
          "application/oebps-package+xml"
          "application/pdf"
          "application/vnd.ms-word.document.macroenabled.12"
          "application/vnd.oasis.opendocument.text"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/x-cb7"
          "application/x-cbc"
          "application/x-cbr"
          "application/x-cbz"
          "application/x-mobi8-ebook"
          "application/x-mobipocket-ebook"
          "application/x-mobipocket-subscription"
          "application/x-sony-bbeb"
          "application/xhtml+xml"
          "image/vnd.djvu"
          "text/fb2+xml"
          "text/html"
          "text/plain"
          "text/rtf"
          "text/x-markdown"
        ];
      in (
        builtins.listToAttrs (builtins.map (mimeType: {
            name = mimeType;
            value = desktopName;
          })
          mimeTypes)
      );
    }
  ]);
}
