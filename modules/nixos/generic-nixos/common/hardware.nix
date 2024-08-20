{
  config,
  lib,
  pkgs,
  ...
}: let
  isDesktop = config.generic-nixos.role == "desktop";
  inherit (lib) mkOverride;
in {
  boot.kernelPackages = mkOverride 999 (
    if isDesktop
    then pkgs.linuxPackages_zen
    else pkgs.linuxPackages_6_6_hardened
  );

  boot.kernelModules = ["wireguard"];

  # NOTE: these firmware will be loaded if kernel requested <2023-10-03>
  hardware.enableAllFirmware = mkOverride 999 (pkgs.config.allowUnfree);
  hardware.enableRedistributableFirmware = mkOverride 999 true;

  services.libinput = {
    enable = mkOverride 999 true;
    # mouse.accelProfile = "flat";
  };

  # sound
  sound.enable = mkOverride 999 isDesktop;
  security.rtkit.enable = mkOverride 999 isDesktop;
  hardware.pulseaudio.enable = false;

  # bluetooth
  hardware.bluetooth.enable = mkOverride 999 isDesktop;

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

  # opengl
  hardware.opengl = {
    enable = mkOverride 999 isDesktop; # should be enabled by other modules
    driSupport = mkOverride 999 isDesktop;
    driSupport32Bit = mkOverride 999 isDesktop;
  };

  hardware.i2c.enable = mkOverride 999 isDesktop;

  # hardware.steam-hardware.enable = mkOverride 999 (
  #   pkgs.config.allowUnfree && isDesktop
  # );
}
