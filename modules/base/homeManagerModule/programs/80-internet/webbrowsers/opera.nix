{
  lib,
  config,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config =
    lib.mkIf
      (baseHomeCfg.isDesktop && baseHomeCfg.isHome && pkgs.stdenv.isLinux && pkgs.config.allowUnfree)
      {
        services.flatpak.packages = [
          # NOTE: opera is only browser that suport netflix 1080p on linux <2024-11-24>
          # https://help.netflix.com/en/node/30081
          "com.opera.Opera"
        ];

        xdg.mimeApps.associations.removed =
          let
            desktopName = "com.opera.Opera.desktop";
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
