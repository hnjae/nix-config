{
  pkgs,
  lib,
  config,
  ...
}: {
  config =
    lib.mkIf (
      config.services.xserver.desktopManager.gnome.enable
    ) {
      environment.systemPackages = with pkgs; [
        gnomeExtensions.tray-icons-reloaded
      ];

      home-manager.sharedModules = [
        {
          dconf.settings = {
            "org/gnome/shell".enabled-extensions = [
              "trayIconsReloaded@selfmade.pl"
            ];
            "org/gnome/shell/extensions/trayIconsReloaded" = {
              icon-size = 20;
            };
          };
        }
      ];
    };
}
