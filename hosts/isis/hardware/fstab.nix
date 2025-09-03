{ lib, ... }:
{
  ###############
  # ZFS-related #
  ###############

  boot.supportedFilesystems.zfs = lib.mkForce true;
  virtualisation.docker.storageDriver = "zfs";
  virtualisation.containers.storage.settings.storage.driver = "zfs";

  # NOTE: 이걸로도 syt <2025-09-03>
  systemd.targets.local-fs = {
    after = [ "zfs-import.target" ]; # 기본: local-fs-pre.target
    wants = [ "zfs-mount.service" ];
  };
  systemd.services.systemd-vconsole-setup = {
    after = [ "local-fs.target" ];
    wants = [ "local-fs.target" ];
  };

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
    }
  ];

  #########
  # FSTAB #
  #########

  boot.tmp.useTmpfs = false; # for large build

  fileSystems = {
    "/" = {
      device = "isis/local/root";
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
