/*
  ZFS 에 의해 마운트 되는 경로:
    /home
*/
{ config, lib, ... }:
{
  boot.supportedFilesystems.zfs = lib.mkForce true;
  virtualisation.docker.storageDriver = "zfs";
  virtualisation.containers.storage.settings.storage.driver = "zfs";

  systemd.targets.local-fs = {
    after = [ "zfs-import.target" ]; # 기본: local-fs-pre.target
    wants = [ "zfs-mount.service" ];
  };
  systemd.services.systemd-vconsole-setup.after = [ "local-fs.target" ];

  home-manager.sharedModules = [
    {
      /*
        NOTE: <2024-11-28>
          zfs is not supported in rooltless podman
          https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md
      */
      xdg.configFile."containers/storage.conf" = {
        # podman config
        text = ''
          [storage]
          driver = "overlay"
        '';
      };
    }
  ];
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

  boot.supportedFilesystems.ntfs = true;

  sops.secrets = {
    "horus-samba-credential" = {
      sopsFile = ./secrets/horus-samba-credential;
      format = "binary";
    };
  };

  systemd.automounts = [
    {
      where = "/media/windows";
      wantedBy = [ "multi-user.target" ]; # runlevel4
    }
    {
      where = "/media/music";
      wantedBy = [ "multi-user.target" ];
    }
  ];

  systemd.mounts = [
    {
      what = "/dev/disk/by-partuuid/0d0c92ae-52da-422a-b8be-487a713d7aa3";
      type = "ntfs";
      where = "/media/windows";
      mountConfig = {
        Options = builtins.concatStringsSep "," [
          # https://docs.kernel.org/filesystems/ntfs3.html
          "prealloc"
          "windows_names"
          "sys_immutable"
          "nohidden"
        ];
      };
    }
    {
      # what = "//eris/music";
      what = "eris:music";
      type = "nfs";
      where = "/media/music";
      after = [
        "tailscaled.service"
        "network-online.target"
        "systemd-resolved.service"
      ];
      wants = [
        "tailscaled.service"
        "network-online.target"
        "systemd-resolved.service"
      ];
      mountConfig = {
        Options = builtins.concatStringsSep "," [
          "vers=4"
          "nfsvers=4"
          # "rsize=16384"
          # "wsize=16384"
          # "rsize=1048576"
          # "wsize=1048576"
          "rsize=524288"
          "wsize=524288"
          "ac" # cache
          # "credentials=${config.sops.secrets.horus-samba-credential.path}"
          # "uid=1000"
          # "gid=100"
          # "file_mode=0600"
          # "dir_mode=0700"
          # "cache=strict"
          # "noacl"
        ];
      };
    }
  ];
}
