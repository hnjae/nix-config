# for lofree flow keyboard (and apple keyboard (maybe))
{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.base-nixos.role == "baremetal") {

    /*
      NOTE: udev 로는 bluetooth 연결의 경우를 커버하지 못함. <2024-04-29>
      services.udev.extraRules = ''
        ACTION=="add", ATTRS{product}=="Flow84@Lofree", ATTR{idProduct}=="024f" ATTR{idVendor}=="05ac", RUN+="${pkgs.dash}/bin/dash -c 'echo 2 > /sys/module/hid_apple/parameters/fnmode'"
      '';
    */

    boot.extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };
}
