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
      # NOTE: tray-icons-reloaded does not support syncthingtray <2024-11-19>
      # environment.systemPackages = with pkgs; [
      #   gnomeExtensions.tray-icons-reloaded
      # ];
      #
      # home-manager.sharedModules = [
      #   {
      #     dconf.settings = {
      #       "org/gnome/shell".enabled-extensions = [
      #         "trayIconsReloaded@selfmade.pl"
      #       ];
      #       "org/gnome/shell/extensions/trayIconsReloaded" = {
      #         icon-size = 20;
      #         icon-padding-horizontal = 4;
      #         icon-margin-horizontal = 4;
      #         tray-margin-left = 4;
      #       };
      #     };
      #   }
      # ];

      environment.systemPackages = with pkgs; [
        gnomeExtensions.appindicator
      ];
      home-manager.sharedModules = [
        {
          dconf.settings = {
            "org/gnome/shell".enabled-extensions = [
              "appindicatorsupport@rgcjonas.gmail.com"
            ];
            "org/gnome/shell/extensions/appindicator" = {
              icon-opacity = 255;
              icon-saturation = 0.25;
            };
          };
        }
      ];
    };
}
