{ lib, ... }:
{
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
    }
  ];

  # zfs 파티션이 마운트 되기전에 local-fs 에 reach 하는 것을 방지.
  systemd.targets.local-fs = {
    wants = [
      "zfs-mount.service"
    ];
    # default after: local-fs-pre.target (NixOS 25.05)
    # After 에 zfs-mount.service 추가 안하면, mount 가 local-fs 이후에 일어나는 경우도 있다.
    # 근데 원래 `.target` 을 wants 가 전부 만족한 후에 Reach 하는 것 아니었나?
    after = [
      "zfs-mount.service"
      "zfs-import.target"
    ];
  };

  #############################
  # Impermanence fixed        #
  #############################
  # NOTE: systemd-vconsole-setup 이 여전히 너무 빠르게 실행됨. <2025-09-03>
  # `/etc/vconsole.conf` 는 initrd-nixos-activation.service 에 의해 생성되어서, 딱히 문제가 없을텐데.. 왜 안되냐.
  # vconsole 은 local-fs 와는 관계 없을 것.
  systemd.services.systemd-vconsole-setup = {
    wants = [
      "local-fs.target"
    ];
    after = [
      "local-fs.target"
    ];
  };

  systemd.services.display-manager = {
    wants = [
      "systemd-vconsole-setup.service"
    ];
    after = [
      "systemd-vconsole-setup.service"
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
