{
  lib,
  pkgs,
  ...
}:
let
  enableSecrueboot = true;
in
{
  boot = {
    lanzaboote = {
      enable = enableSecrueboot;
      pkiBundle = "/etc/secureboot";
      settings.console-mode = "keep"; # use vendor's firmware's default
    };
    loader = {
      # NOTE: lanzaboote replace the systemd-boot module
      systemd-boot = {
        enable = lib.mkForce (!enableSecrueboot);
        memtest86.enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

    kernelParams = [
      # 백라이트가 갑자기 꺼지는 문제 해결 (WIP; 테스트 안됨; 6.12.19; NixOS 24.11)
      # https://forums.lenovo.com/t5/Other-Linux-Discussions/ThinkPad-T16-Gen-1-on-Linux-backlight-switches-off-once-in-a-while/m-p/5260463
      "amdgpu.dcdebugmask=0x10" # turn off Panel-Self-Refresh (PSR)
    ];
  };

  environment.systemPackages = [
    # for secure-boot
    pkgs.sbctl
  ];
}
