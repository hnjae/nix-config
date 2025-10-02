{ config, ... }:
{
  sops.secrets."eris-samba-credential" = {
    sopsFile = ./secrets/eris-samba-credential;
    format = "binary";
  };
  systemd.automounts = [
    {
      where = "/media/vault";
      wantedBy = [ "multi-user.target" ];
    }
  ];

  systemd.mounts = [
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
          "rsize=1048576"
          "wsize=1048576"
        ];
      };
    }
  ];
}
