{
  inputs,
  lib,
  ...
}:
pkgs:
(lib.flatten [
  pkgs.git # for flake.nix
  pkgs.git-lfs # lfs 쓰는 git clone 할때 필요함.

  pkgs.nh # nix CLI wrapper
  # nix-shell -c, nix-index wrapper
  # comma

  # Basic features
  pkgs.coreutils # cp/mv/chown ...
  pkgs.psmisc # killall
  pkgs.bc # bc
  pkgs.iputils # ping
  pkgs.sysstat # iostat
  pkgs.python3 # ansible / etc

  # lsxxx
  pkgs.lsof
  pkgs.pciutils # lspci
  pkgs.usbutils # lsusb

  # Get hardware info
  pkgs.dmidecode
  pkgs.lm_sensors
  pkgs.lshw

  ###############
  # Requires root privilege
  ###############
  pkgs.hdparm # access physical device's firmware, ...
  pkgs.dosfstools # mkfs.vfat
  pkgs.powertop

  ###############
  # Misc
  ###############
  pkgs.rsbkb # crc32
  pkgs.xxHash
  pkgs.beep # Advanced PC speaker beeper
  pkgs.lsb-release
  pkgs.sysstat # iostat
  pkgs.file

  ###############
  # filesystems/progs
  ###############
  pkgs.cryptsetup
  pkgs.gptfdisk # cgdisk
  pkgs.btrfs-progs
  pkgs.e2fsprogs
  pkgs.exfatprogs
  pkgs.f2fs-tools
  pkgs.udftools
  pkgs.dosfstools # mkfs.vfat
  pkgs.nfs-utils
  pkgs.cifs-utils
  pkgs.sshfs
  pkgs.compsize # calculate btrfs compressed size

  ###############
  # access physical device's firmware, ...
  ###############
  pkgs.smartmontools
  pkgs.hddtemp
  pkgs.nvme-cli
  pkgs.sedutil # for OPAL NVMe

  ###############
  # Monitor
  ###############
  pkgs.kmon # linux kernel activity monitor
  pkgs.htop
  (lib.hiPrio (
    pkgs.makeDesktopItem {
      name = "htop";
      desktopName = "Htop";
      genericName = "Process Viewer";
      icon = "htop";
      # exec = ''${pkgs.wezterm}/bin/wezterm start --class=htop -e htop'';
      exec = ''wezterm start --class=htop -e htop'';
      categories = [
        "System"
        "Monitor"
      ];
      keywords = [
        "system"
        "process"
        "task"
      ];
    }
  ))

  ###############
  # some "modern" utils (https://github.com/ibraheemdev/modern-unix)
  ###############
  pkgs.bat
  pkgs.eza # lsd 는 ANSI color 안써서 eza 쓰자. <2023-10-05; lsd v0.23.1>
  pkgs.fd
  pkgs.hexyl # replace od
  pkgs.just
  pkgs.procs # replace ps
  pkgs.viddy # replace watch
  pkgs.fzf
  pkgs.ripgrep
  pkgs.my.nixvim
  pkgs.nushell
  pkgs.unstable.lazydocker
  pkgs.starship
  pkgs.unstable.just
  (pkgs.symlinkJoin {
    # duf: fancy du
    name = "duf-ansi";
    paths = [
      (pkgs.writeScriptBin "duf" ''
        #!${pkgs.dash}/bin/dash

        exec "${pkgs.duf}/bin/duf" --theme=ansi "$@"
      '')
      pkgs.duf # for man page
    ];
  })
  pkgs.unstable.joshuto
  (lib.hiPrio (
    pkgs.makeDesktopItem {
      name = "joshuto";
      desktopName = "joshuto";
      genericName = "File Manager";
      icon = "system-file-manager";
      mimeTypes = [ "inode/directory" ];
      # exec = ''${pkgs.wezterm}/bin/wezterm start --class=joshuto -e joshuto'';
      exec = ''wezterm start --class=joshuto -e joshuto'';
      categories = [
        "System"
        "FileTools"
        "FileManager"
      ];
      keywords = [
        "File"
        "Manager"
        "Browser"
        "Explorer"
      ];
    }
  ))
  pkgs.jq
  pkgs.yq # sed for json/yaml
  pkgs.fio
  pkgs.tree
  # pkgs.du-dust # dust(du)
  # pkgs.gping # gping(ping)
  # pkgs.doggo # doggo(dig)

  ###############
  # Archives
  ###############
  pkgs.ouch # archive handler
  pkgs.unrar
  pkgs.unzipNLS
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
    ]
  )

  ###############
  # MISC
  ###############
  pkgs.pwgen
  pkgs.wireguard-tools
  pkgs.rclone
  pkgs.rustic
  pkgs.rsync
  pkgs.man-pages
  pkgs.man-pages-posix
])
