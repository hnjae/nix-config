{
  config,
  pkgs,
  lib,
  ...
}: let
  isDesktop = config.generic-nixos.role == "desktop";
in {
  config = lib.mkIf (config.generic-nixos.role == "desktop") {
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
    # services.pipewire.wireplumber = {
    # };

    # environment.etc."wireplumber/policy.lua.d/11-bluetooth-policy.lua" = {
    #   # disable auto profile switch
    #   # NixOS 23.11 기준 autoswitch 를 키면 매뉴얼 프로파일 스위치가 안되는 경우가 많았음.
    #   # TODO: NixOS 24.05 에서는 wireplumber 관련 모듈 추가 되었으니, 판올림할때 확인할
    #   # 것.
    #   enable = mkOverride 999 isDesktop;
    #   text = ''
    #     -- Whether to use headset profile in the presence of an input stream.
    #     bluetooth_policy.policy["media-role.use-headset-profile"] = false
    #   '';
    # };

    # environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua" = {
    #   enable = mkOverride 999 isDesktop;
    #   text = ''
    #     bluez_monitor.properties = {
    #       ["bluez5.a2dp.ldac.quality"] = "sq", -- 660
    #     }
    #   '';
    # };
    # ["bluez5.a2dp.aac.bitratemode"] = 1,
    # ["bluez5.enable-sbc-xq"] = true,
    # ["bluez5.enable-msbc"] = true,
    # ["bluez5.codecs"] = "[ aac ldac aptx aptx_hd aptx_ll aptx_ll_duplex faststream faststream_duplex ]",
  };
}
