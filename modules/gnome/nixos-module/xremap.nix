{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.services.xserver.desktopManager.gnome.enable) {
    environment.systemPackages = with pkgs; [
      gnomeExtensions.xremap
    ];

    home-manager.sharedModules = [
      {
        dconf.settings = {
          "org/gnome/shell".enabled-extensions = [
            # "appindicatorsupport@rgcjonas.gmail.com"
          ];
        };
      }
    ];
  };
}
