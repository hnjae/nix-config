# TODO: 브라우저 로그인이 필요한 caffe wifi 를 사용할때, 어떻게 해야하는지 모르겠음 <2025-05-15>
# > If you cannot get to the login page of the capitive portal, try to access a non-ssl site like http://neverssl.com
# https://learn.microsoft.com/ko-kr/windows-hardware/drivers/mobilebroadband/captive-portals
# https://wiki.archlinux.org/title/NetworkManager
# https://wiki.debian.org/CaptivePortal

# TODO: 다음 적용해보자 <2025-05-15>
# https://www.reddit.com/r/archlinux/comments/1fef59s/using_a_captive_portal_with_a_manually_locked/

# TODO: resolved 가 켜져있으면, starbucks wifi 에 연결 조차 불가능. (captive-portal 로 인증 그 이전에) <2025-05-15>
# org.freedesktop.resolve1

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

    environment.systemPackages = lib.lists.optional (cfg.hostType == "baremetal") pkgs.captive-browser;

    # bluetooth
    hardware.bluetooth = {
      enable = mkProfileDefault true;
      # settings = {
      #   General = {
      #     Experimental = true;
      #   };
      # };
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
