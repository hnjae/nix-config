/*
  README:
    - <https://zrepl.github.io/configuration/jobs.html>
    - `recv` 단에도 설정 추가해야함.
*/

{
  pkgs,
  lib,
  self,
  ...
}:
let
  fileSystems = {
    "osiris/safe<" = true;
  };

  # zfs send 전에 snapshot 을 찍어, 항상 가장 최신 상태를 보낸다.
  # NOTE: echo "foo$(date)" 식의 명령어의 경우 date 가 fail 할 경우에 `set -eu` 적용이 되질 않음. <2025-07-19>
  backupOnsite = pkgs.writeScriptBin "backup-onsite" ''
    #!${pkgs.dash}/bin/dash

    set -eu

    PATH="${
      lib.makeBinPath [
        pkgs.coreutils # date
        pkgs.zrepl
      ]
    }"

    ZFS_CMD='/run/booted-system/sw/bin/zfs'

    time_="$(date --utc '+%Y-%m-%dT%H:%M:%S.%3NZ')"
    "$ZFS_CMD" snapshot -r -- "osiris/safe@zrepl_''${time_}"
    echo "[INFO]: Created snapshot osiris/safe@zrepl_''${time_}" >&2

    zrepl signal wakeup -- 'osiris-push'
    echo '[INFO]: Wakeup signal sent to zrepl job "osiris-push"' >&2
  '';
in
{
  environment.systemPackages = [ backupOnsite ];

  services.zrepl.enable = true;

  services.zrepl.settings.jobs = [
    {
      name = "osiris-snap"; # must not change
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
            regex = "^(zrepl|rustic)_.*";
          }
          {
            type = "last_n";
            count = 7;
            regex = "^(zrepl|rustic)_.*";
          }
          {
            type = "regex";
            negate = true;
            regex = "^(zrepl|rustic)_.*";
          }
        ];
      };
    }
    {
      name = "osiris-push"; # must-not-change
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
        compressed = true;
        embedded_data = true;
      };
      replication = {
        protection = {
          initial = "guarantee_resumability";
          incremental = "guarantee_resumability";
        };
      };
      snapshotting = {
        type = "manual"; # no snapshot managing by this zrepl job
      };
      pruning = {
        keep_sender = [
          # KEEP ALL
          {
            type = "regex";
            regex = ".*";
          }
        ];
        # NOTE: zrepl send 에서는 보낼 snapshot 지정이 안된다. host 의 모든 snapshot 이 전송됨. 그래서 keep_receiver 의 regex 로 cleanup 할 snapshot 을 제한해서는 안됨. <2025-07-19>
        keep_receiver = [
          {
            type = "grid";
            grid = "1x1h(keep=all) | 24x1h | 7x1d | 3x7d";
            regex = "^(zrepl|rustic)_.*";
          }
          {
            type = "last_n";
            count = 7;
            regex = "^(zrepl|rustic)_.*";
          }
        ];
      };
    }
  ];

  systemd =
    let
      jobName = "osiris-push";
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
          OnStartupSec = "20m";
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
          ExecCondition = "${self.packages.${pkgs.system}.check-metered}";
          ExecStart = "${backupOnsite}/bin/backup-onsite";
          SuccessExitStatus = 1; # zrepl prints the following if job is in progress: "already woken up" and exits with 1.
        };
      };
    };

  services.zfs = {
    autoScrub = {
      enable = true;
      pools = [ "osiris" ];
    };
    trim = {
      enable = true;
    };
  };
}
