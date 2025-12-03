{ pkgs, ... }:
{
  environment.defaultPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd

    # infos
    clinfo # opencl
    mesa-demos # glxinfo
    vulkan-tools
    libva-utils
  ];

  hardware.amdgpu = {
    initrd.enable = false;
    opencl.enable = false;
  };

  # services.lact = { # Use this module in NixOS 25.11
  #   enable = true;
  # };
  hardware.amdgpu.overdrive.enable = true;

  environment.systemPackages = [ pkgs.lact ];
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
      1002:67FF-1682:9550-0000:0a:00.0:
        fan_control_enabled: true
        fan_control_settings:
          mode: curve
          static_speed: 0.5
          temperature_key: edge
          interval_ms: 500
          curve:
            40: 0.0
            50: 0.0
            60: 0.4
            70: 0.75
            80: 1.0
          spindown_delay_ms: 0
          change_threshold: 0
        performance_level: low
        voltage_offset: -2
    current_profile: null
  '';
}
