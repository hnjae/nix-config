/*
  NOTE:
  snapshot 시스템이 반드시 존재해야 한다. zrepl 는 latest snapshot 을 기준으로 복제를 진행하는 것 같다. <2025-03-16>
*/

{
  pkgs,
  lib,
  ...
}:
let
  dataset = "eris/safe";
  fileSystems = {
    "${dataset}<" = true;
  };
in
{
  services.zrepl.enable = true;

  services.zrepl.settings.jobs = [
    # {
    #   name = "eris-snap"; # must not change
    #   type = "snap";
    #   filesystems = fileSystems;
    #   snapshotting = {
    #     type = "periodic";
    #     prefix = "zrepl_";
    #     interval = "1h";
    #     timestamp_format = "iso-8601";
    #   };
    #   pruning = {
    #     keep = [
    #       {
    #         type = "grid";
    #         grid = "1x1h(keep=all) | 24x1h | 10x1d | 4x7d";
    #         regex = "^(zrepl|rustic)_.*";
    #       }
    #       {
    #         type = "last_n";
    #         count = 8;
    #         regex = "^(zrepl|rustic)_.*";
    #       }
    #       {
    #         type = "regex";
    #         negate = true;
    #         regex = "^(zrepl|rustic)_.*";
    #       }
    #     ];
    #   };
    # }
    {
      name = "eris-push"; # must-not-change
      type = "push";
      connect = {
        type = "tcp";
        address = "127.0.0.1:65535";
        dial_timeout = "12s"; # optional, 0 for no timeout
      };
      filesystems = fileSystems;
      send = {
        encrypted = false; # cobalt have loaded encryption keys
        large_blocks = true; # must-not-change after initial replication
        compressed = false;
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
          # {
          #   type = "regex";
          #   regex = ".*";
          # }
          {
            type = "grid";
            grid = "1x1h(keep=all) | 24x1h | 10x1d | 4x7d";
            regex = "^(zrepl|rustic)_.*";
          }
          {
            type = "last_n";
            count = 8;
            regex = "^(zrepl|rustic)_.*";
          }
          {
            type = "regex";
            negate = true;
            regex = "^(zrepl|rustic)_.*";
          }
        ];
        # NOTE: zrepl send 에서는 보낼 snapshot 지정이 안된다. host 의 모든 snapshot 이 전송됨. 그래서 keep_receiver 의 regex 로 cleanup 할 snapshot 을 제한해서는 안됨. <2025-07-19>
        keep_receiver = [
          {
            type = "grid";
            grid = "1x1h(keep=all) | 24x1h | 10x1d | 4x7d";
            regex = "^(zrepl|rustic)_.*";
          }
          {
            type = "last_n";
            count = 8;
            regex = "^(zrepl|rustic)_.*";
          }
        ];
      };
    }
  ];

  systemd =
    let
      jobName = "eris-push"; # must-not-change
      serviceName = "zfs-replication-eris";
      description = "Create snapshot and send signal to zrepl job ${jobName}";
      documentation = [ "https://zrepl.github.io/configuration.html" ];
    in
    {
      timers."${serviceName}" = {
        inherit description documentation;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnStartupSec = "30m";
          OnUnitInactiveSec = "60m";
          RandomizedDelaySec = "5m";
          Persistent = false; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.
          # OnCalendar = "hourly";
        };
      };

      services."${serviceName}" = {
        inherit description documentation;
        unitConfig = rec {
          Requires = [
            "zfs-import.target"
            "zrepl.service"
          ];
          After = Requires;
          ConditionACPower = true;
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "zfs-replication-${dataset}" ''
            set -euo pipefail

            JOBNAME='${jobName}'
            ZFS_CMD='/run/booted-system/sw/bin/zfs'
            PATH="${
              lib.makeBinPath [
                pkgs.coreutils # date
                pkgs.zrepl
                pkgs.jq
              ]
            }"

            is_push_running() {
              local is_done
              is_done=$(zrepl status --mode raw | jq -r --arg job "$JOBNAME" '
                .Jobs[$job].push as $push |
                ($push.PruningSender == null) and ($push.PruningReceiver == null) and ($push.Replication ==null)
              ')

              if "$is_done"; then
                return 1
              else
                return 0
              fi
            }

            main() {
              time_="$(date --utc '+%Y-%m-%dT%H:%M:%S.%3NZ')"

              echo "[INFO]: Creating snapshot ${dataset}@zrepl_''${time_}" >&2
              "$ZFS_CMD" snapshot -r -- "${dataset}@zrepl_''${time_}"

              if is_push_running; then
                echo "[INFO]: Previous zrepl job ${jobName} is still running" >&2
              else
                echo '[INFO]: Sending wakeup signal to zrepl job "${jobName}"' >&2
                zrepl signal wakeup -- "$JOBNAME"
              fi
            }

            main
          '';
        };
      };
    };
}
