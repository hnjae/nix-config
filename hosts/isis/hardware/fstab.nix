/*
  ZFS 에 의해 마운트 되는 경로:
    /home
*/
{ config, lib, ... }:
{
  boot.supportedFilesystems.zfs = lib.mkForce true;

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
      where = "/run/media/windows";
      wantedBy = [ "multi-user.target" ]; # runlevel4
    }
    {
      where = "/run/media/music";
      wantedBy = [ "multi-user.target" ];
    }
  ];

  systemd.mounts = [
    {
      what = "/dev/disk/by-partuuid/0d0c92ae-52da-422a-b8be-487a713d7aa3";
      type = "ntfs";
      where = "/run/media/windows";
      # wantedBy = [ "local-fs.target" ];
      # before = [ "local-fs.target" ];
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
      what = "//horus/music";
      type = "smb3";
      where = "/run/media/music";
      # wantedBy = [ "remote-fs.target" ];
      # before = [ "remote-fs.target" ];
      after = [
        "tailscaled.service"
        "network-online.target"
        "systemd-resolved.service"
      ];
      requires = [
        "tailscaled.service"
        "network-online.target"
        "systemd-resolved.service"
      ];
      mountConfig = {
        Options = builtins.concatStringsSep "," [
          "credentials=${config.sops.secrets.horus-samba-credential.path}"
          "uid=1000"
          "gid=100"
          "file_mode=0600"
          "dir_mode=0700"
          "cache=strict"
          "noacl"
        ];
      };
    }
  ];
}
