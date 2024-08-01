{
  pkgs,
  config,
  extraConfig,
  ...
}: {
  imports = [
    ./vim.nix
    ./desktop.nix
    ./filesystem.nix
    ./shell.nix
    ./busybox-alike.nix
    ./fonts.nix
  ];

  environment.systemPackages = with config.boot.kernelPackages; [
    cpupower
    x86_energy_perf_policy
  ];

  # Set of default packages that aren't strictly necessary for a running system
  environment.defaultPackages = with pkgs; [
    dash
    elvish

    # nix-shell -c, nix-index wrapper
    comma

    # for nixos/nix
    perl
    rsync
    strace
    # for flake
    git

    file
    sysstat # iostat
    dosfstools # mkfs.vfat
    lsof
    beep
    wget

    # Get hardware info
    pciutils # lspci
    lshw
    usbutils # lsusb
    dmidecode
    lm_sensors

    # some basic utils
    dig
    curl
    lsb-release

    # some "modern" utils
    fd
    ripgrep
    eza
    hexyl # replace od
    procs # replace ps
    viddy # replace watch

    # archives
    unzip
    p7zip
    _7zz

    # misc
    pwgen
    wireguard-tools

    # tops
    bottom
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
