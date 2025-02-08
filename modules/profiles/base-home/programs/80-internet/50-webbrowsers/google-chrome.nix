{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config =
    lib.mkIf
      (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64 && pkgs.config.allowUnfree)
      {
        home.packages = [
          # (pkgs.google-chrome.override {
          #   # NOTE: gtk-version=4 flag 안먹음 <2024-06-05>
          #   commandLineArgs =
          #     builtins.concatStringsSep
          #     " " [
          #       "--ozone-platform-hint=auto"
          #       "--enable-features=UseOzonePlatform"
          #       "--enable-wayland-ime"
          #       "--wayland-text-input-version=3"
          #       # "--enable-features=WaylandWindowDecorations"
          #       # "--enable-features=VaapiVideoDecoder"
          #       # "--enable-features=VaapiIgnoreDriverChecks"
          #     ];
          # })
        ];

        stateful.nodes = [
          {
            path = "${config.xdg.configHome}/google-chrome";
            mode = "700";
            type = "dir";
          }
          {
            path = "${config.xdg.configHome}/google-chrome-beta";
            mode = "700";
            type = "dir";
          }
          {
            path = "${config.xdg.configHome}/google-chrome-unstable";
            mode = "700";
            type = "dir";
          }
        ];

        services.flatpak.packages = [
          "com.google.Chrome"
        ];

        xdg.dataFile."applications/com.google.Chrome.desktop" =
          let
            flags = [
              # enable wayland
              "--ozone-platform-hint=auto"
              "--enable-features=UseOzonePlatform"
              # enable text-input-v3
              "--enable-wayland-ime"
              "--wayland-text-input-version=3"
              # enable vaapi
              "--enable-features=AcceleratedVideoDecodeLinuxGL"
              "--enable-features=VaapiIgnoreDriverChecks"
              # enable vulakn support
              # NOTE: enabling vulkan disable video play in wavve.com <2024-12-25>
              # "--enable-features=Vulkan"
            ];
            flagStr = builtins.concatStringsSep " " flags;
          in
          {
            text = ''
              [Desktop Entry]
              Version=1.0
              Name=Google Chrome
              GenericName=Web Browser
              Comment=Access the Internet
              Exec=flatpak run --branch=stable --command=/app/bin/chrome --file-forwarding com.google.Chrome ${flagStr} @@u %U @@
              StartupNotify=true
              Terminal=false
              Icon=com.google.Chrome
              Type=Application
              Categories=Network;WebBrowser;
              MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
              Actions=new-window;new-private-window;
              X-Flatpak-Tags=proprietary;
              X-Flatpak=com.google.Chrome

              [Desktop Action new-window]
              Name=New Window
              Exec=flatpak run --branch=stable --command=/app/bin/chrome com.google.Chrome ${flagStr}

              [Desktop Action new-private-window]
              Name=New Incognito Window
              Exec=flatpak run --branch=stable --command=/app/bin/chrome com.google.Chrome ${flagStr} --incognito
            '';
          };
      };
}
