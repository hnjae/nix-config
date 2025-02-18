{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
  appId = "org.mozilla.firefox";
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    services.flatpak.packages = [ appId ];

    services.flatpak.overrides.${appId}.Context = {
      # to access home directory
      filesystems = [ "home" ];
    };

    home.packages = [
      (pkgs.writeScriptBin "firefox" ''
        #!${pkgs.dash}/bin/dash

        flatpak run ${appId} "$@"
      '')
    ];

    stateful.nodes = [
      {
        path = "${config.home.homeDirectory}/.mozilla";
        mode = "755";
        type = "dir";
      }
    ];

    xdg.mimeApps.associations.removed =
      let
        desktopName = "${appId}.desktop";
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
