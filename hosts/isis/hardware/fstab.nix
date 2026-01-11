{ lib, ... }:
{
  systemd.tmpfiles.rules = [
    # flatpak ns ZFS dataset 이라 생기는 경로 삭제
    "R /home/hnjae/.local/share/flatpak/.Trash-1000 - - - - "
  ];

  ###############
  # ZFS-related #
  ###############

  boot.supportedFilesystems.zfs = lib.mkForce true;
  virtualisation.docker.storageDriver = "zfs";
  virtualisation.containers.storage.settings.storage.driver = "zfs";

  # run `head -c4 /dev/urandom | od -A none -t x4`
  networking.hostId = "e177869e"; # for ZFS. hexadecimal characters.

  home-manager.sharedModules = [
    {
      /*
        NOTE: <2024-11-28>
          zfs is not supported in rooltless podman
          https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md
      */
      xdg.configFile."containers/storage.conf" = {
        text = ''
          [storage]
          driver = "overlay"
        '';
      };
      home.sessionVariables = {
        UV_LINK_MODE = "copy"; # ~/.cache 가 다른 볼륨에 있음.
      };
    }
  ];

  # zfs 파티션이 마운트 되기전에 local-fs 에 reach 하는 것을 방지.
  systemd.targets.local-fs = {
    wants = [
      "zfs-mount.service"
    ];
    # default after: local-fs-pre.target (NixOS 25.05)
    after = [
      "zfs-import.target"
    ];
  };

  #########
  # FSTAB #
  #########

  boot.tmp.useTmpfs = false; # for large build

  fileSystems = {
    "/" = {
      device = "isis/local/rootfs";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/nix" = {
      device = "isis/local/nix";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/nix/var" = {
      device = "isis/local/nix_var";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/ISIS_EFISYS";
      fsType = "vfat";
      options = [
        "noatime"
        "nodev"
        "nosuid"
        "noexec"
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/persist" = {
      device = "isis/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/secrets" = {
      device = "isis/safe/secrets";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  ################
  # impermanence #
  ################

  environment.persistence."/persist/@" = {
    hideMounts = true;
    enableWarnings = false;
    files = [
      "/etc/machine-id"
    ];
    directories = [
      {
        # NOTE: /var/log 를 zfs dataset 으로 관리하면 poweroff 할때 unmount fail issue 뜸. <2025-08-23>
        directory = "/var/log";
        mode = "0755";
      }
    ];
  };
}
