# NOTE: opera is only browser that support netflix 1080p on linux <2024-11-24>
# https://help.netflix.com/en/node/30081
{
  lib,
  config,
  pkgs,
  ...
}:
let
  appId = "com.opera.Opera";

  baseHomeCfg = config.base-home;
  cond =
    baseHomeCfg.isDesktop
    && baseHomeCfg.isHome
    && pkgs.stdenv.isLinux
    && pkgs.stdenv.isx86_64
    && pkgs.config.allowUnfree;
in
{
  config = lib.mkIf (cond) {
    services.flatpak.packages = [ appId ];

    # xdg.dataFile."applications/${appId}.desktop" =
    #   let
    #     flags = lib.escapeShellArgs [
    #       "--enable-features=UseOzonePlatform"
    #       "--ozone-platform-hint=auto"
    #     ];
    #   in
    #   {
    #     text = ''
    #       [Desktop Entry]
    #       Version=1.0
    #       Name=Opera
    #       GenericName=Web Browser
    #       Comment=Fast and secure web browser
    #       StartupNotify=true
    #       StartupWMClass=Opera
    #       Exec=flatpak run --branch=stable --arch=x86_64 --command=opera --file-forwarding ${appId} ${flags} @@u %U @@
    #       Terminal=false
    #       Icon=${appId}
    #       Type=Application
    #       Categories=Network;WebBrowser;
    #       MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ipfs;x-scheme-handler/ipns;application/x-opera-download;
    #       Actions=new-window;new-private-window;
    #       X-Flatpak=${appId}
    #
    #       [Desktop Action new-window]
    #       Name=New Window
    #       Exec=flatpak run --branch=stable --arch=x86_64 --command=opera ${appId} ${flags} --new-window
    #
    #       [Desktop Action new-private-window]
    #       Name=New Incognito Window
    #       Exec=flatpak run --branch=stable --arch=x86_64 --command=opera ${appId} ${flags} --incognito
    #
    #     '';
    #   };

    xdg.mimeApps.associations.removed =
      let
        desktopName = "${appId}.desktop";
        mimeTypes = [
          "application/pdf"
          "application/rdf+xml"
          "application/rss+xml"
          "application/xhtml+xml"
          "application/xhtml_xml"
          "application/xml"
          "image/gif"
          "image/jpeg"
          "image/png"
          "image/webp"
          "text/html"
          "text/xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/ipfs"
          "x-scheme-handler/ipns"
        ];
      in
      (builtins.listToAttrs (
        builtins.map (mimeType: {
          name = mimeType;
          value = desktopName;
        }) mimeTypes
      ));
  };

}
