# NOTE: <https://zrepl.github.io/configuration/jobs.html>
let
  fileSystems = {
    "isis/safe<" = true;
    "isis/safe/home/hnjae/.cache<" = false;
  };
in
{
  services.zrepl.enable = true;

  services.zrepl.settings.jobs = [
    {
      name = "isis-snap"; # must not change
      type = "snap";
      filesystems = fileSystems;
      snapshotting = {
        type = "periodic";
        prefix = "zrepl_";
        interval = "1h";
        timestamp_format = "iso-8601";
      };
      pruning = {
        keep = [
          {
            type = "grid";
            grid = "1x1h(keep=all) | 24x1h | 7x1d | 3x7d";
            regex = "^(zrepl|autosnap)_.*";
          }
          {
            type = "last_n";
            count = 7;
            regex = "^(zrepl|autosnap)_.*";
          }
          {
            type = "regex";
            negate = true;
            regex = "^(zrepl|autosnap)_.*";
          }
        ];
      };
    }
    {
      name = "isis-push"; # must-not-change
      type = "push";
      # connect = {
      #   type = "local";
      #   listener_name = "replica";
      #   client_identity = "replica";
      # };
      connect = {
        type = "tcp";
        address = "horus:65535";
        dial_timeout = "12s"; # optional, 0 for no timeout
      };
      filesystems = fileSystems;
      send = {
        encrypted = false; # cobalt have loaded encryption keys
        large_blocks = true; # must-not-change after initial replication
        compressed = true; # yes compression because it is remote
      };
      replication = {
        protection = {
          initial = "guarantee_incremental";
          incremental = "guarantee_incremental";
          /*
            NOTE:
              guarantee_incremental 를 사용하는 경우: e.g. 외장 HDD 에 사용하는 경우.
              복제 과정 중 백업 드라이브를 분리하는게 가능한 경우.
          */
        };
      };
      snapshotting = {
        type = "manual"; # no snapshot managing by this
      };
      pruning = {
        keep_sender = [
          # KEEP ALL
          {
            type = "regex";
            negate = true;
            regex = ".*";
          }
        ];
        keep_receiver = [
          {
            type = "grid";
            grid = "1x1h(keep=all) | 24x1h | 7x1d | 3x7d";
            regex = "^(autosnap|zrepl)_.*";
          }
          {
            type = "last_n";
            count = 7;
            regex = "^(zrepl|autosnap)_.*";
          }
          {
            type = "regex";
            negate = true;
            regex = "^(autosnap|zrepl)_.*";
          }
        ];
      };
    }
  ];
}
