{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  appId = "org.libreoffice.LibreOffice";
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = [
      appId
      "org.gtk.Gtk3theme.adw-gtk3"
    ];

    services.flatpak.overrides."${appId}" = {
      "Session Bus Policy" = {
        # INFO: global menu won't work on KDE <NixOS 24.05; LibreOffice 24.2.5.2>
        "com.canonical.AppMenu.Registrar" = "none";
      };
      Context = {
        # INFO: 기본으로 host 파일을 전부 읽을 수 있게 설정되어 있음.  <2024-08-10>
        filesystems = [
          "home"
          "!host"
        ];
      };
      Environment = {
        "GTK_THEME" = "adw-gtk3";
      };
    };

    default-app.mime = {
      "application/vnd.oasis.opendocument.text" = "org.libreoffice.LibreOffice.writer";
      "application/vnd.oasis.opendocument.spreadsheet" = "org.libreoffice.LibreOffice.calc";
      "application/vnd.oasis.opendocument.presentation" = "org.libreoffice.LibreOffice.impress";

      "application/vnd.oasis.opendocument.text-template" = "org.libreoffice.LibreOffice.writer";
      "application/vnd.oasis.opendocument.spreadsheet-template" = "org.libreoffice.LibreOffice.calc";
      "application/vnd.oasis.opendocument.presentation-template" = "org.libreoffice.LibreOffice.impress";

      # "application/vnd.oasis.opendocument.text-flat-xml" = "org.libreoffice.LibreOffice.writer";
      # "application/vnd.oasis.opendocument.text-master" = "org.libreoffice.LibreOffice.writer";
      # "application/vnd.oasis.opendocument.text-master-template" = "org.libreoffice.LibreOffice.writer";
      # "application/vnd.oasis.opendocument.text-web" = "org.libreoffice.LibreOffice.writer";

      # "application/vnd.oasis.opendocument.chart" = "org.libreoffice.LibreOffice.calc";
      # "application/vnd.oasis.opendocument.chart-template" = "org.libreoffice.LibreOffice.calc";
      # "application/vnd.oasis.opendocument.spreadsheet-flat-xml" = "org.libreoffice.LibreOffice.calc";

      # "application/vnd.oasis.opendocument.presentation-flat-xml" = "org.libreoffice.LibreOffice.impress";

      # "application/vnd.oasis.opendocument.base" = "org.libreoffice.LibreOffice.base";

      # "application/vnd.oasis.opendocument.graphics" = "org.libreoffice.LibreOffice.draw";
      # "application/vnd.oasis.opendocument.graphics-flat-xml" = "org.libreoffice.LibreOffice.draw";
      # "application/vnd.oasis.opendocument.graphics-template" = "org.libreoffice.LibreOffice.draw";

      # "application/vnd.oasis.opendocument.formula" = "org.libreoffice.LibreOffice.math";
      # "application/vnd.oasis.opendocument.formula-template" = "org.libreoffice.LibreOffice.math";
    };
  };
}
