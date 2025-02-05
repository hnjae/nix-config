{
  config,
  pkgs,
  lib,
  ...
}:
let
  isDesktop = config.base-nixos.role == "desktop";
in
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    boot.kernelPackages = lib.mkOverride 950 pkgs.linuxPackages_zen;
    services.libinput = {
      enable = lib.mkOverride 999 true;
      # mouse.accelProfile = "flat";
    };

    # bluetooth
    hardware.bluetooth = {
      enable = isDesktop;
      # settings = {
      #   General = {
      #     Experimental = true;
      #   };
      # };
    };

    # sound
    security.rtkit.enable = lib.mkOverride 999 true;
    hardware.pulseaudio.enable = false; # use pipewire

    # opengl
    hardware.graphics = {
      enable = lib.mkOverride 999 true;
      enable32Bit = lib.mkOverride 999 isDesktop;
    };

    hardware.i2c.enable = lib.mkOverride 999 isDesktop;
  };
}
