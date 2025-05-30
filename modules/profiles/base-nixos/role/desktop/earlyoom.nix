{ config, lib, ... }:
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    services.systembus-notify.enable = true;
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
      extraArgs = [
        "--ignore-root-user"
        "--prefer"
        # top, pstree, ps -e
        "(^|/)(chromium|chrome|brave|opera|firefox-bin|zen)$"
        # "--avoid"
      ];
    };
  };
}
