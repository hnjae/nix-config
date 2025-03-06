{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;

  appId = "app.zen_browser.zen";
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    default-app.browser = appId;
    services.flatpak.packages = [ appId ];

    # services.flatpak.overrides."${appId}" = {
    #   "Session Bus Policy" = {
    #     "org.freedesktop.Flatpak" = "talk";
    #   };
    #
    #   # do I need this?
    #   "System Bus Policy" = {
    #     "org.freedesktop.Flatpak" = "talk";
    #   };
    # };

    xdg.mimeApps.associations.removed =
      let
        desktopName = "${appId}.desktop";
        mimeTypes = [
          "application/pdf"
          "application/json"
          "text/xml"
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
