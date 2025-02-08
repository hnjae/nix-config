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
    default-app.browser = "app.zen_browser.zen";
    services.flatpak.packages = [
      "app.zen_browser.zen"
    ];
    xdg.mimeApps.associations.removed =
      let
        desktopName = "app.zen_browser.zen.desktop";
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
