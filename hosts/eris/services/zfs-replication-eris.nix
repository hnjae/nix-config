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

  jobName = "eris-push"; # must-not-change
  serviceName = "zfs-replication-eris";

  script = pkgs.writeShellScript serviceName ''
    set -Eeuo pipefail

    PATH="${
      lib.makeBinPath [
        pkgs.util-linux # flock
        pkgs.coreutils # date
        pkgs.zrepl
        pkgs.jq
      ]
    }"
    readonly ZFS_CMD='/run/booted-system/sw/bin/zfs'
    readonly LOCK_TIMEOUT="3600"
    readonly LOCKFILE_1="/var/lock/zpool-cobalt.lock"
    readonly LOCKFILE_2="/var/lock/zpool-eris.lock" # eris pool lock

    log() { printf '[%s] %s\n' "$1" "$2" >&2; }

    release_lock() {
      local lock="$1" fdvar="$2"

      local fd="''${!fdvar-}"

      if [ "$fd" != "" ]; then
        flock -u "$fd" 2>/dev/null || true
        log INFO "Released lock: {lock: '$lock', fd: '$fd'}"

        # Close file descriptor $fd ( `>&-` 구문에 변수 사용이 불가하므로 eval 사용)
        eval "exec ''${fd}>&-" 2>/dev/null || true

        # lock 을 acquired 하지 않을 경우 삭제 안함.
        [ -f "$lock" ] && rm -f "$lock" 2>/dev/null
      fi
    }

    cleanup_lock() {
      # 트랩 재진입 방지
      trap - EXIT ERR INT TERM

      local rc=$?

      log INFO "Cleaning up locks"
      release_lock "$LOCKFILE_2" fd_2
      release_lock "$LOCKFILE_1" fd_1

      log INFO "Script finished with exit code: $rc"
      exit "$rc"
    }

    acquire_lock() {
      local lock="$1" fdvar="$2"

      if ! exec {fd}>"$lock"; then
        log ERROR "Cannot create lock file: '$lock'"
        exit 1
      fi

      log INFO "Acquiring lock: '$lock' (timeout: ''${LOCK_TIMEOUT}s)"
      if ! flock -w "$LOCK_TIMEOUT" "$fd"; then
        log ERROR "Lock not acquired for '$lock' within ''${LOCK_TIMEOUT}s"
        exit 75 # EX_TEMPFAIL (Temporaryfailure,  indicating something that is not really an error.)
      fi
      log INFO "Lock acquired: {lock: '$lock', fd: '$fd'}"

      # 호출자에게 FD 번호를 넘겨줌
      printf -v "$fdvar" '%s' "$fd"
    }

    is_push_running() {
      local is_done
      is_done=$(zrepl status --mode raw | jq -r --arg job "${jobName}" '
        .Jobs[$job].push as $push |
        (
          (
            ($push.PruningSender == null)
            and ($push.PruningReceiver == null)
            and ($push.Replication ==null)
          )
          or
          (
            ($push.PruningSender != null and $push.PruningSender.State == "Done")
            and ($push.PruningReceiver != null and $push.PruningReceiver.State == "Done")
            and (($push.Replication != null) and ($push.Replication.Attempts | all(.State == "done")))
          )
        )
      ')

      if "$is_done"; then
        return 1
      else
        return 0
      fi
    }

    wait_for_job_done() {
      local initial_interval=10
      local max_interval=90
      local current_interval=$initial_interval
      local elapsed=40

      log INFO "Monitoring job '${jobName}' with adaptive polling..."

      sleep "$elapsed"
      while is_push_running; do
        log INFO "Job '${jobName}' still running... (checking every ''${current_interval}s)"

        sleep "$current_interval"
        elapsed=$((elapsed + current_interval))

        # 점진적으로 폴링 간격 증가
        if [ "$current_interval" -lt "$max_interval" ]; then
          current_interval=$((current_interval + 4))
        fi
      done

      local halv=$((current_interval/2))
      log INFO "Job '${jobName}' completed in $((elapsed - halv))±''${halv}s"
    }

    main() {
      if [ "''${EUID:-$UID}" != 0 ]; then
        log ERROR "This script must be run as root"
        exit 1
      fi

      if is_push_running; then
        # 유저가 zrepl signal 을 직접 보내거나 했을 경우, 이 분기로 들어갈 수 있음.
        log INFO "Previous job still running: '${jobName}'"
        return 0
      fi

      trap cleanup_lock EXIT INT TERM ERR
      acquire_lock "$LOCKFILE_1" fd_1
      acquire_lock "$LOCKFILE_2" fd_2

      # Replication 직전에 snapshot 을 찍어, 최신의 snapshot 을 보냄.
      time_="$(date --utc '+%Y-%m-%dT%H:%M:%S.%3NZ')"
      "$ZFS_CMD" snapshot -r -- "${dataset}@zrepl_''${time_}"
      log INFO "Created snapshot: ${dataset}@zrepl_''${time_}"

      log INFO "Sending wakeup signal to zrepl: '${jobName}'"
      zrepl signal wakeup -- '${jobName}'
      wait_for_job_done
    }

    main
  '';
in
{
  services.zrepl.enable = true;

  services.zrepl.settings.jobs = [
    {
      name = "eris-snap"; # must not change
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
      };
    }
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
          {
            type = "regex";
            regex = ".*";
          }
          # {
          #   type = "grid";
          #   grid = "1x1h(keep=all) | 24x1h | 10x1d | 4x7d";
          #   regex = "^(zrepl|rustic)_.*";
          # }
          # {
          #   type = "last_n";
          #   count = 8;
          #   regex = "^(zrepl|rustic)_.*";
          # }
          # {
          #   type = "regex";
          #   negate = true;
          #   regex = "^(zrepl|rustic)_.*";
          # }
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
      description = "Create snapshot and send signal to zrepl job ${jobName}";
      documentation = [ "https://zrepl.github.io/configuration.html" ];
    in
    {
      timers."${serviceName}" = {
        inherit description documentation;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnStartupSec = "150m";
          OnUnitInactiveSec = "300m"; # 5h
          RandomizedDelaySec = "15m";
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
          ExecStart = script;
        };
      };
    };
}
