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

  boot.kernelParams = [
    # Low-battery (<20%) 에서 전력 소모를 줄이기 위해, 색상 정확도를 낮추는 기능 끄기.
    # https://discussion.fedoraproject.org/t/update-reduces-color-accuracy-in-favor-of-power-efficiency-amd-gpu/124723
    "amdgpu.abmlevel=0"
    "amdgpu.aspm=1"
  ];

  # 표준 경로에 링크하여, 프로그램에서 쉽게 참조할 수 있도록 한다.
  systemd.tmpfiles.rules = [
    "L /usr/share/vulkan - - - - /run/current-system/sw/share/vulkan"
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

  environment.systemPackages = with pkgs; [
    lact
  ];

  hardware.amdgpu = {
    initrd.enable = false;
    opencl = {
      enable = true;
    };
  };

  nixpkgs.config.rocmSupport = true;

  #######
  # LACT
  #######
  # services.lact = { # Use this module in NixOS 25.11
  #   enable = true;
  # };
  hardware.amdgpu.overdrive.enable = true;

  systemd.packages = [ pkgs.lact ];

  systemd.services.lactd = {
    description = "LACT GPU Control Daemon";
    wantedBy = [ "multi-user.target" ];
    # Restart when the config file changes.
    # restartTriggers = lib.mkIf (cfg.settings != { }) [ configFile ];
  };

  environment.etc."lact/config.yaml".text = ''
    daemon:
      log_level: info
      admin_groups:
      - wheel
      - sudo
      disable_clocks_cleanup: false
    apply_settings_timer: 5
    gpus:
      1002:73DF-1EAE:6606-0000:09:00.0:
        fan_control_enabled: false
        performance_level: auto
        voltage_offset: -50
    current_profile: null
  '';
  # power_cap: 163.0
}
