{ config, lib, ... }:
{
  boot.supportedFilesystems.ntfs = true;

  sops.secrets = {
    "eris-samba-credential" = {
      sopsFile = ./secrets/eris-samba-credential;
      format = "binary";
    };
  };
  systemd.automounts = [
    {
      where = "/media/windows";
      wantedBy = [ "multi-user.target" ]; # runlevel4
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
  ];
}
