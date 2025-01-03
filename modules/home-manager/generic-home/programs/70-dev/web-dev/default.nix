{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      # A modern load testing tool, using Go and JavaScript
      k6

      # httpie # sends http requests
      xh #  friendly and fast tool for sending HTTP requests.
    ];

    services.flatpak.packages = lib.lists.concatLists [
      (lib.lists.optionals (genericHomeCfg.isDesktop)
        [
          "com.usebruno.Bruno" # Proprietary # https://github.com/usebruno/bruno mit
        ])
      (lib.lists.optionals (genericHomeCfg.isDesktop && genericHomeCfg.installTestApps)
        [
          "com.usebruno.Bruno" # Proprietary # https://github.com/usebruno/bruno mit
          "io.httpie.Httpie" # Proprietary
          # "rest.insomnia.Insomnia" # mit
          # "com.getpostman.Postman" # Proprietary
        ])
    ];

    # # NOTE: use xwayland <2024-12-11>
    services.flatpak.overrides."com.usebruno.Bruno" = lib.mkIf (genericHomeCfg.isDesktop) {
      Context = {
        sockets = ["!wayland"];
      };
    };
    xdg.dataFile."applications/com.usebruno.Bruno.desktop" = lib.mkIf (genericHomeCfg.isDesktop) {
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
