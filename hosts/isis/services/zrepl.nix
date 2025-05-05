# NOTE: <https://zrepl.github.io/configuration/jobs.html>
{ pkgs, config, ... }:
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
      connect = {
        type = "tcp";
        address = "horus:65535";
        dial_timeout = "12s"; # optional, 0 for no timeout
      };
      filesystems = fileSystems;
      send = {
        encrypted = false; # cobalt have loaded encryption keys
        large_blocks = true; # must-not-change after initial replication
        compressed = true; # > Streams sent with -c will not have their data recompressed on the receiver side using -o compress= value.
        # compressed = true;
      };
      replication = {
        protection = {
          # initial = "guarantee_resumability";
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

  systemd =
    let
      jobName = "isis-push"; # must-not-change

      serviceName = "zrepl-signal-${jobName}";
      description = "Zrepl signal ${jobName}";
      documentation = [ "https://zrepl.github.io/configuration.html" ];
    in
    {
      timers."${serviceName}" = {
        inherit description documentation;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          AccuracySec = "1m";
          OnStartupSec = "30m";
          OnUnitInactiveSec = "90m";
          Persistent = false; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.
          WakeSystem = false;
        };
      };

      services."${serviceName}" = {
        inherit description documentation;
        unitConfig = rec {
          BindsTo = [
            "zrepl.service"
            "zfs-import.target"
          ];
          Wants = [ "network-online.target" ];
          After = BindsTo ++ Wants;
          ConditionACPower = true;
        };

        serviceConfig = {
          Type = "oneshot";
          inherit (config.systemd.services.restic-backup-off-site.serviceConfig) ExecCondition;
          ExecStart = "${pkgs.zrepl}/bin/zrepl signal wakeup ${jobName}";
          SuccessExitStatus = 1; # zrepl prints if job is in progress: "already woken up" and exits with 1.
        };
      };
    };
}
