/*
  NOTE:
  Kernel 6.18 기준

  btrfs-scrub 이 SIGINT 시 `1` 로 종료되는 것과 달리, btrfs-balance 는 `130` 으로 종료.
*/
let
  serviceName = "btrfs-balance";
  target = "/nix";
  poolName = "eris";
in
{
  pkgs,
  lib,
  ...
}:
let
  script = pkgs.writeShellScript "btrfs-balance@${target}" ''
    set -Eeuo pipefail

    PATH="${
      lib.makeBinPath (
        with pkgs;
        [
          util-linux # flock
          btrfs-progs
        ]
      )
    }"

    log() {
      local level="$1" msg="$2"
      local prefix
      case "$level" in
        ERROR)  prefix='<3>' ;;
        WARN)   prefix='<4>' ;;
        INFO)   prefix='<6>' ;;
        DEBUG)  prefix='<7>' ;;
        *)      prefix='<6>'; level='INFO' ;;
      esac
      printf '%s%s: %s\n' "$prefix" "$level" "$msg" >&2
    }

    readonly LOCK_TIMEOUT="7200" # 2 hours
    readonly LOCKFILE="/run/lock/pool-${poolName}.lock" # eris pool lock
    readonly TARGET="${target}"

    release_lock() {
      local lock="$1" fdvar="$2"
      local fd="''${!fdvar-}"

      if [ "$fd" != "" ]; then
        flock -u "$fd" 2>/dev/null || true
        log INFO "Released lock: {lock: '$lock', fd: '$fd'}"

        # Close file descriptor $fd (use eval since >&- doesn't accept variables)
        eval "exec ''${fd}>&-" 2>/dev/null || true
      fi
    }

    cleanup_lock() {
      local rc=$? # Exit Code of the Previous Command

      # Prevent trap reentry
      trap - EXIT ERR INT TERM

      if [ "''${CLEANUP_RUNNING:-0}" = "1" ]; then
        log ERROR "BUG: Cleanup function called twice"
        exit 1
      fi
      CLEANUP_RUNNING=1

      log INFO "Cleaning up lock(s)"
      release_lock "$LOCKFILE" fd

      exit "$rc"
    }

    acquire_lock() {
      local lock="$1" fdvar="$2"

      if ! exec {fd}>"$lock"; then
        log ERROR "Cannot create lock file: $lock"
        exit 1
      fi

      log INFO "Acquiring lock: '$lock' (timeout: ''${LOCK_TIMEOUT}s)"

      if ! flock -w "$LOCK_TIMEOUT" "$fd"; then
        log ERROR "Lock not acquired for '$lock' within ''${LOCK_TIMEOUT}s"
        exit 75 # EX_TEMPFAIL (Temporaryfailure, indicating something that is not really an error.)
      fi

      log INFO "Lock acquired: {lock: '$lock', fd: '$fd'}"

      # Pass FD number to caller
      printf -v "$fdvar" '%s' "$fd"
    }

    main() {
      trap cleanup_lock EXIT ERR INT TERM
      acquire_lock "$LOCKFILE" fd

      for BB in 0 5 10; do
        log INFO "Starting data balance with usage threshold: ''${BB}%"
        if ! btrfs balance start -dusage="$BB" -- "$TARGET"; then
          log ERROR "Data balance failed at ''${BB}% threshold"
          exit 1
        fi
      done

      for BB in 0 5; do
        log INFO "Starting metadata balance with usage threshold: ''${BB}%"
        if ! btrfs balance start -musage="$BB" -- "$TARGET"; then
          log ERROR "Metadata balance failed at ''${BB}% threshold"
          exit 1
        fi
      done
    }

    main
  '';
in
{
  systemd =
    let
      description = "Run btrfs balance on /nix";
      documentation = [ "man:btrfs-balance(8)" ];
    in
    {
      services.${serviceName} = {
        inherit description documentation;
        requires = [
          "local-fs.target"
        ];
        after = [
          "local-fs.target"
          "multi-user.target"
        ];

        serviceConfig = {
          Type = "simple"; # long-running operations

          # 커널 스케쥴링
          Nice = 19;
          IOSchedulingClass = "idle";

          # NOTE: https://github.com/kdave/btrfsmaintenance
          ExecStart = script;

          # Hardening
          NoNewPrivileges = true;
          PrivateNetwork = true; # No network needed
          ProtectClock = true;
          ProtectKernelModules = true;
        };
      };

      timers.${serviceName} = {
        inherit description documentation;
        timerConfig = {
          OnCalendar = [
            "Mon *-*-* 01:55:00"
          ];
          RandomizedDelaySec = "5m";
          Persistent = "true";
        };

        wantedBy = [ "timers.target" ];
      };
    };
}
