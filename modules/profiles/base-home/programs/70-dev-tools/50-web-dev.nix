{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    services.flatpak.packages = builtins.concatLists [
      [
        "com.usebruno.Bruno" # Proprietary in flathub but MIT license in repo <https://github.com/usebruno/bruno>
        # "io.httpie.Httpie" # Proprietary
        # "rest.insomnia.Insomnia" # mit
        # "com.getpostman.Postman" # Proprietary
      ]
    ];

    # NOTE: use xwayland <2024-12-11>
    services.flatpak.overrides."com.usebruno.Bruno" = lib.mkIf (baseHomeCfg.isDesktop) {
      Context = {
        sockets = [ "!wayland" ];
      };
    };

    xdg.dataFile."applications/com.usebruno.Bruno.desktop" = lib.mkIf (baseHomeCfg.isDesktop) {
      text = ''
        [Desktop Entry]
        Name=Bruno
        Exec=flatpak run --branch=stable --command=bruno --file-forwarding com.usebruno.Bruno --ozone-platform-hint=x11 @@u %U @@
        Terminal=false
        Type=Application
        Icon=com.usebruno.Bruno
        StartupWMClass=Bruno
        MimeType=x-scheme-handler/bruno;
        Categories=Development;
        X-Flatpak=com.usebruno.Bruno
      '';
    };
  };
}
