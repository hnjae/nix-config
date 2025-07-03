# vi:tw=0:
{
  config,
  lib,
  ...
}:
let
  appId = "org.telegram.desktop";
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && baseHomeCfg.isHome) {
    services.flatpak.packages = [
      appId # GPL3
    ];
    services.flatpak.overrides."${appId}" = {
      Context = {
        filesystems = [
          "xdg-download"
        ];
      };
    };

    xdg.dataFile."applications/${appId}" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Telegram Desktop
        Comment=Run telegram with custom .desktop file
        Exec=flatpak run --branch=stable --command=telegram-desktop --file-forwarding org.telegram.desktop -- @@u %u @@
        Icon=org.telegram.desktop
        Terminal=false
        StartupWMClass=TelegramDesktop
        Type=Application
        Categories=Chat;Network;InstantMessaging;Qt;
        MimeType=x-scheme-handler/tg;
        Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
        Actions=quit;
        # DBusActivatable=true

        SingleMainWindow=true
        X-GNOME-UsesNotifications=true
        X-GNOME-SingleWindow=true
        X-Flatpak=org.telegram.desktop

        [Desktop Action quit]
        Exec=flatpak run --branch=stable --arch=x86_64 --command=telegram-desktop org.telegram.desktop -quit
        Name=Quit Telegram
        Icon=application-exit
      '';
    };
  };
}
