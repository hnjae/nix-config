/*
ZFS 에 의해 마운트 되는 경로:
  /home
*/
{lib, ...}: {
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
      options = ["noatime" "nodev" "nosuid" "noexec" "fmask=0077" "dmask=0077"];
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
  systemd.mounts = [
    {
      what = "/dev/disk/by-partuuid/0d0c92ae-52da-422a-b8be-487a713d7aa3";
      type = "ntfs";
      where = "/run/media/windows";
      wantedBy = ["local-fs.target"];
      before = ["local-fs.target"];
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
  ];
}
