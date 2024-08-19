{
  config,
  lib,
  pkgs,
  ...
}: {
  # networking.networkmanager.enable = config.services.xserver.enable;
  networking.networkmanager = {
    enable = lib.mkOverride 999 true;
    plugins = with pkgs; [
      networkmanager_strongswan
    ];
  };

  services.dbus.packages =
    lib.lists.optional
    config.networking.networkmanager.enable
    pkgs.strongswanNM;
}
