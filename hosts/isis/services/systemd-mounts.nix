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
