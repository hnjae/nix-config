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
      requires = [
        "tailscaled.service"
        "network-online.target"
        "systemd-resolved.service"
      ];
      mountConfig = {
        Options = builtins.concatStringsSep "," [
          "nfsvers=4"
          "rsize=65536"
          "wsize=65536"
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
      requires = [
        "tailscaled.service"
        "network-online.target"
        "systemd-resolved.service"
      ];
      mountConfig = {
        Options = builtins.concatStringsSep "," [
          "nfsvers=4"
          "rsize=65536"
          "wsize=65536"
        ];
      };
    }

  ];
}
