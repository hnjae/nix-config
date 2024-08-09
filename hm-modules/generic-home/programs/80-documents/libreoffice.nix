{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
  appId = "org.libreoffice.LibreOffice";
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
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
        filesystems = ["home" "!host"];
      };
      Environment = {
        "GTK_THEME" = "adw-gtk3";
      };
    };
  };
}
