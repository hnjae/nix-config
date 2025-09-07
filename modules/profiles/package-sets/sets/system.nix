_: pkgs: with pkgs; [
  git # for flake.nix

  # Basic features
  coreutils # cp/mv/chown ...
  psmisc # killall
  bc # bc
  iputils # ping
  sysstat # iostat

  # lsxxx
  lsof
  pciutils # lspci
  usbutils # lsusb

  # Get hardware info
  dmidecode
  lm_sensors
  lshw

  # Requires root privilege
  hdparm # access physical device's firmware, ...
  dosfstools # mkfs.vfat
  powertop

  # Misc
  rsbkb # crc32
  beep # Advanced PC speaker beeper
  lsb-release
  sysstat # iostat
  file

  my.nixvim

  nh # nix CLI wrapper
  # nix-shell -c, nix-index wrapper
  # comma

  # filesystems/progs
  cryptsetup
  gptfdisk # cgdisk
  btrfs-progs
  e2fsprogs
  exfatprogs
  f2fs-tools
  udftools
  dosfstools # mkfs.vfat
  nfs-utils
  cifs-utils
  sshfs
  compsize # calculate btrfs compressed size

  # access physical device's firmware, ...
  smartmontools
  hddtemp
  nvme-cli
  sedutil # for OPAL NVMe

  # some "modern" utils
  bat
  eza
  fd
  hexyl # replace od
  just
  procs # replace ps
  ripgrep
  tree
  viddy # replace watch
  fzf

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

  # MISC
  pwgen
  wireguard-tools
  jq
  python3
  starship
  # (wezterm.overrideAttrs (_: {
  #   passthru.cargoBuildFlags = [
  #     "--package"
  #     "wezterm-mux-server"
  #   ];
  # }))
  htop
]
