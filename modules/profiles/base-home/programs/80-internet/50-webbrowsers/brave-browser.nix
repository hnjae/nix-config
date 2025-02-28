{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  appId = "com.brave.Browser";
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux && pkgs.stdenv.is64bit) {
    services.flatpak.packages = [ appId ];
    services.flatpak.overrides."${appId}" = {
      "Session Bus Policy" = {
        "org.freedesktop.Flatpak" = "talk";
      };
    };

    xdg.mimeApps.associations.removed =
      let
        desktopName = "${appId}.desktop";
        mimeTypes = [
          "application/pdf"
          "application/rdf+xml"
          "application/rss+xml"
          "image/gif"
          "image/jpeg"
          "image/png"
          "image/webp"
          "text/xml"
        ];
      in
      (builtins.listToAttrs (
        builtins.map (mimeType: {
          name = mimeType;
          value = desktopName;
        }) mimeTypes
      ));

    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/BraveSoftware";
        mode = "700";
        type = "dir";
      }
    ];
  };
}
