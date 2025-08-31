{
  systemd.automounts = [
    {
      where = "/media/music";
      wantedBy = [ "multi-user.target" ];
    }
    {
      where = "/media/vault";
      wantedBy = [ "multi-user.target" ];
    }
  ];

  systemd.mounts = [
    {
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
          "nfsvers=4"
          "rsize=1048576"
          "wsize=1048576"
        ];
      };
    }
    {
      what = "eris:vault";
      type = "nfs";
      where = "/media/vault";
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
          "nfsvers=4"
          # "rsize=65536"
          # "wsize=65536"
          "rsize=1048576"
          "wsize=1048576"
        ];
      };
    }

  ];
}
