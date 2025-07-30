{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./busybox-alike.nix
    ./filesystem.nix
    ./shell.nix
  ];

  programs.nano.enable = false;

  environment.systemPackages = [
    config.boot.kernelPackages.cpupower
    config.boot.kernelPackages.x86_energy_perf_policy
    pkgs.nixvim
  ];

  # Set of default packages that aren't strictly necessary for a running system
  environment.defaultPackages = lib.flatten [
    (with pkgs; [
      # nix CLI wrapper
      nh

      # nix-shell -c, nix-index wrapper
      # comma

      # for NixOS/nix
      perl
      rsync
      strace
      git # for flake.nix

      # some basic utils
      beep
      curl
      dig
      file
      lsb-release
      lsof
      sysstat # iostat
      wget

      # Get hardware info
      dmidecode
      lm_sensors
      lshw
      pciutils # lspci
      usbutils # lsusb

      # some "modern" utils
      bat
      # bottom # tops
      eza
      fd
      hexyl # replace od
      just
      procs # replace ps
      ripgrep
      tree
      viddy # replace watch

      # MISC
      pwgen
      wireguard-tools
      jq

      # (wezterm.overrideAttrs (_: {
      #   passthru.cargoBuildFlags = [
      #     "--package"
      #     "wezterm-mux-server"
      #   ];
      # }))
    ])

    # archives
    pkgs.unrar
    (
      let
        package7z = pkgs._7zz.override { enableUnfree = pkgs.config.allowUnfree; };
      in
      [
        package7z
        (pkgs.runCommandLocal "p7zip" { } ''
          mkdir -p "$out/bin"
          ln -s "${package7z}/bin/7zz" "$out/bin/7z"
        '')
        pkgs.unzipNLS
      ]
    )
  ];

  programs.htop = {
    enable = true;
    settings = {
      hide_kernel_threads = true;
      hide_userland_threads = true;
      hide_running_in_container = false;
      show_thread_names = false;
      show_program_path = false;
      highlight_base_name = true;

      shadow_other_users = true;

      show_cpu_frequency = true;
      show_cpu_usage = true;
      header_layout = "three_33_34_33";

      # column_meters_0 = "LeftCPUs2 Memory Zram";
      # column_meter_modes_0 = "1 1 1";
      # column_meters_1 = "RightCPUs2 CPU Swap";
      # column_meter_modes_1 = "1 1 1";
      # column_meters_2 = "Hostname System Systemd Tasks LoadAverage Uptime";
      # column_meter_modes_2 = "2 2 2 2 2 2";
    };
  };
}
