# WIP - testing
{ pkgs, ... }:
{
  services.garage = {
    enable = true;
    package = pkgs.garage_1_0_1;
    settings = {
      metadata_dir = "/garage/metadata";
      data_dir = [
        {
          capacity = "64G";
          path = "/garage/data1";
        }
        {
          capacity = "64G";
          path = "/garage/data2";
        }
      ];

      db_engine = "sqlite";
      replication_factor = 1;

      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";
      rpc_secret = "zzzz";

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = "s3.garage.localhost";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = "web.garage.localhost";
        index = "index.html";
      };
      k2v_api = {
        api_bind_addr = "[::]:3904";
      };
      admin = {
        api_bind_addr = "[::]:3903";
        admin_token = "zzzz";
        metrics_token = "zzzz";
      };
    };
  };
  systemd.mounts = [
    {
      what = "/dev/zvol/isis/test1";
      type = "ext4";
      where = "/garage/data1";
      wantedBy = [ "local-fs.target" ];
      before = [ "local-fs.target" ];
      mountConfig = {
        Options = builtins.concatStringsSep "," [
          "noatime"
          "nodev"
          "nosuid"
        ];
      };
    }
    {
      what = "/dev/zvol/isis/test2";
      type = "ext4";
      where = "/garage/data2";
      wantedBy = [ "local-fs.target" ];
      before = [ "local-fs.target" ];
      mountConfig = {
        Options = builtins.concatStringsSep "," [
          "noatime"
          "nodev"
          "nosuid"
        ];
      };
    }
  ];
}
