{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.base-nixos;
  mkProfileDefault = lib.mkOverride 999;
in
{
  config = lib.mkIf (cfg.role == "desktop") {
    services.libinput = {
      enable = mkProfileDefault true;
      # mouse.accelProfile = "flat";
    };

    # network
    networking.networkmanager = {
      enable = mkProfileDefault true;
      plugins = with pkgs; [
        networkmanager_strongswan
      ];
      # wifi.backend = mkProfileDefault "iwd"; # NixOS 24.11 기준 unstable 함
    };

    services.dbus.packages = [ pkgs.strongswanNM ];

    # bluetooth
    hardware.bluetooth = {
      enable = mkProfileDefault true;
    };

    # sound
    security.rtkit.enable = mkProfileDefault true;

    # opengl
    hardware.graphics = {
      enable = mkProfileDefault true;
      enable32Bit = mkProfileDefault true;
    };

    hardware.i2c.enable = mkProfileDefault true;
  };
}
