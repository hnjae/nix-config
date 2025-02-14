{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = [
      "org.mozilla.firefox"
    ];

    xdg.mimeApps.associations.removed =
      let
        desktopName = "org.mozilla.firefox.desktop";
        mimeTypes = [
          # "application/rdf+xml"
          # "application/rss+xml"
          "application/xml"
          "audio/flac"
          "audio/ogg"
          "audio/webm"
          "image/avif"
          "image/gif"
          "image/jpeg"
          "image/png"
          "image/svg+xml"
          "image/webp"
          "text/xml"
          "video/ogg"
          "video/webm"
          "x-scheme-handler/mailto"
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
