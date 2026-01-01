{ lib, ... }:
{
  boot.supportedFilesystems.zfs = true;

  boot.initrd = {
    kernelModules = [ "dm-snapshot" ];
    luks.devices = {
      "luks_2203" = {
        device = "/dev/disk/by-partlabel/2203_LUKS";
        preLVM = true;
      };
      "luks_3926" = {
        device = "/dev/disk/by-partlabel/3926_LUKS";
        preLVM = true;
      };
      "luks_3090" = {
        device = "/dev/disk/by-partlabel/3090_LUKS";
        preLVM = true;
      };
    };
    services.lvm.enable = true;
  };

  # NOTE: `nofail` 이 있으면 Before=local-fs.target 이 추가되지 않는 듯. NixOS 25.11
  fileSystems =
    let
      opts = [
        "nodev"
        "nosuid"
        "noatime"
        "noacl"
        "compress=zstd:11"
        "degraded"
        "nodiscard" # use fsync instead
      ];
    in
    {
      "/" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "noatime"
          "mode=0755"
        ];
      };
      "/boot" = {
        label = "3926_ESP";
        fsType = "vfat";
        options = [
          "nofail"
          "noatime"
          "nodev"
          "nosuid"
          "noexec"
          "fmask=0077"
          "dmask=0077"
        ];
      };
      "/boot_fallback_a" = {
        label = "3090_ESP";
        fsType = "vfat";
        options = [
          "nofail"
          "noatime"
          "nodev"
          "nosuid"
          "noexec"
          "fmask=0077"
          "dmask=0077"
        ];
      };
      "/boot_fallback_b" = {
        label = "2203_ESP";
        fsType = "vfat";
        options = [
          "nofail"
          "noatime"
          "nodev"
          "nosuid"
          "noexec"
          "fmask=0077"
          "dmask=0077"
          # "x-systemd.wanted-by=multi-user.target"
        ];
        noCheck = true; # turn off fsck
      };
      "/nix" = {
        label = "ERIS_OS";
        fsType = "btrfs";
        neededForBoot = true;
        options = opts ++ [ "subvol=@nix" ];
      };
      "/zlocal" = {
        label = "ERIS_OS";
        fsType = "btrfs";
        neededForBoot = true;
        options = opts ++ [ "subvol=@zlocal" ];
      };
      "/zsafe" = {
        label = "ERIS_OS";
        fsType = "btrfs";
        neededForBoot = true;
        options = opts ++ [ "subvol=@zsafe" ];
      };
      "/srv" = {
        label = "ERIS_OS";
        fsType = "btrfs";
        options = opts ++ [ "subvol=@srv" ];
      };
    };

  swapDevices =
    builtins.map
      (label: {
        inherit label;
        discardPolicy = "both";
        options = [ "nofail" ];
      })
      [
        "2203_SWAP"
        "3090_SWAP"
        "3926_SWAP"
      ];

  boot.tmp.useTmpfs = false;

  systemd.tmpfiles.rules = [
    # 아래는 이미 포함되어 있음.
    # "d /var/empty 0555 root root -"
    # "h /var/empty - - - - +i"

    "d /home/hnjae 0700 hnjae users -"
    "d /home/hnjae/.cache 0700 hnjae users -"
    "d /home/hnjae/.local 0700 hnjae users -"
    "d /home/hnjae/.local/share 0700 hnjae users -"
    "d /home/hnjae/.local/share/containers 0700 hnjae users -"
  ];

  environment.etc."tmpfiles.d/journal-nocow.conf".text = ''
    # Override default `journal-nocow.conf` to enable CoW

    h /var/log/journal - - - - -C
    h /var/log/journal/%m - - - - -C
    h /var/log/journal/remote - - - - -C
  '';

  # 8 hexadecimal characters.
  # run `head -c4 /dev/urandom | od -A none -t x4`
  # `echo 'eris' | cksum | awk '{printf "%08x\n", $1}'`
  networking.hostId = "5508701d"; # for ZFS. hexadecimal characters.
  virtualisation = {
    docker.storageDriver = "btrfs";
    containers.storage.settings.storage.driver = "btrfs";
  };

  home-manager.sharedModules = [
    {
      xdg.configFile."containers/storage.conf" = {
        # podman config
        text = ''
          [storage]
          driver = "btrfs"
        '';
      };
    }
  ];

  environment.persistence = {
    "/zlocal/@" = {
      hideMounts = true;
      directories = [
        {
          directory = "/home";
          mode = "0755";
        }
        {
          directory = "/var/log";
          mode = "0755";
        }
        {
          directory = "/var/lib/containers";
          mode = "0755";
        }
        {
          directory = "/var/lib/libvirt";
          mode = "0755";
        }
        {
          directory = "/var/lib/systemd/coredump";
          mode = "0755";
        }
        {
          directory = "/var/lib/tailscale";
          mode = "0700";
        }
      ];
      files = [
        "/var/cache/locatedb" # plocate
      ];
    };
    "/zsafe/@" = {
      hideMounts = true;
      files = [
        "/etc/machine-id"
      ];
      directories = [
        {
          # keep uid/gid of auto-generated users (e.g. avahi)
          directory = "/var/lib/nixos";
          mode = "0755";
        }
        {
          directory = "/var/lib/sbctl";
          mode = "0755";
        }
      ];
    };
  };

  # Use FS Compression instead
  nix.settings.compress-build-log = false;
  hardware.firmwareCompression = "none";

  # Extra config options for systemd-coredump. See coredump.conf(5) man page for available options.
  systemd.coredump.extraConfig = ''
    Compress=no
  '';

  # stateless 를 설정하면, cups 가 켜질때 /var/lib/cups 를 지워버림.
  # 어차피 `/` 가 tmpfs 라서 의미 없고, 복잡도 증가.
  services.printing.stateless = lib.mkForce false;

  services.snapper = {
    snapshotRootOnBoot = lib.mkForce false;
    configs =
      let
        commonOpts = {
          FSTYPE = "btrfs";
          COMPRESSION = "none";

          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_MIN_AGE = 1;
          TIMELINE_LIMIT_YEARLY = 0;
          TIMELINE_LIMIT_QUARTERLY = 0;
          TIMELINE_LIMIT_MONTHLY = 0;
          TIMELINE_LIMIT_WEEKLY = 0;
          TIMELINE_LIMIT_DAILY = 14;
          TIMELINE_LIMIT_HOURLY = 12;

          NUMBER_CLEANUP = true;
          NUMBER_MIN_AGE = 1;
          NUMBER_LIMIT = 0;
          NUMBER_LIMIT_IMPORTANT = 0;

          EMPTY_PRE_POST_CLEANUP = true;
          EMPTY_PRE_POST_MIN_AGE = 1;
        };
      in
      {
        "srv" = commonOpts // {
          SUBVOLUME = "/srv";
        };
        "zsafe" = commonOpts // {
          SUBVOLUME = "/zsafe";
        };
      };
  };
}
