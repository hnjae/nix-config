{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/amd/default.nix
    # 하는 것 <2024-08-02>
    # xserver videodriver 를 modesettings 으로, initrd 에서 amdgpu 활성화

    inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  # 표준 경로에 링크하여, 프로그램에서 쉽게 참조할 수 있도록 한다.
  systemd.tmpfiles.rules = [
    "L /usr/share/vulkan - - - - /run/current-system/sw/share/vulkan"
  ];

  boot.kernelParams = [
    # 백라이트가 갑자기 꺼지는 문제 해결 (WIP; 테스트 안됨; 6.12.19; NixOS 24.11)
    # https://forums.lenovo.com/t5/Other-Linux-Discussions/ThinkPad-T16-Gen-1-on-Linux-backlight-switches-off-once-in-a-while/m-p/5260463
    "amdgpu.dcdebugmask=0x10" # turn off Panel-Self-Refresh (PSR)

    # Low-battery (<20%) 에서 전력 소모를 줄이기 위해, 색상 정확도를 낮추는 기능 끄기.
    # https://discussion.fedoraproject.org/t/update-reduces-color-accuracy-in-favor-of-power-efficiency-amd-gpu/124723
    "amdgpu.abmlevel=0"
  ];

  environment.defaultPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd
    (pkgs.runCommandLocal "nvtop-icon-fix" { } ''
      mkdir -p "$out/share/icons/hicolor/scalable/apps/"

      cp --reflink=auto \
        "${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/nvtop.svg" \
        "$out/share/icons/hicolor/scalable/apps/nvtop.svg"
    '')
    (lib.hiPrio (
      pkgs.makeDesktopItem {
        name = "nvtop";
        desktopName = "nvtop";
        genericName = "GPU Process Monitor";
        icon = "nvtop";
        exec = ''${pkgs.wezterm}/bin/wezterm start --class=nvtop -e nvtop'';
        categories = [
          "System"
          "Monitor"
        ];
      }
    ))

    rocmPackages.rocminfo
    rocmPackages.rocm-smi
  ];

  hardware.amdgpu = {
    initrd.enable = false;
    opencl = {
      enable = true;
    };
  };

  nixpkgs.config.rocmSupport = true;

  programs.nix-ld.libraries = with pkgs; [
    vulkan-loader
  ];
}
