/*
  NOTE:
  NixOS 25.11, 6.18
  -`btrfs scrub start` 할때 건내는 `--limit` 플래그는 모든 디바이스가 아니라 한 디바이스에만 limit 이 걸림.

  - ExecStop 따로 안해도, script 종료 되면서 btrfs-scrub 도 종료됨.
  - btrfs scrub 은 SIGINT/SIGTERM 시 1 로 종료
*/
let
  serviceName = "btrfs-scrub";
  target = "/nix";
  poolName = "eris";
in
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # https://btrfs.readthedocs.io/en/latest/btrfs-scrub.html
  isIOPrioClassIdleSupported = lib.elem config.hardware.block.defaultScheduler [
    "bfq"
    "kyber"
  ];
  script = pkgs.writeShellScript "btrfs-scrub@${target}" ''
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
      trap - EXIT ERR

      if [ "''${CLEANUP_RUNNING:-0}" = "1" ]; then
        log ERROR "BUG: Cleanup function called twice"
        exit 1
      fi
      CLEANUP_RUNNING=1

      log INFO "Cleaning up lock(s)"
      release_lock "$LOCKFILE" fd

      exit "$rc"
    }

    # btrfs-scrub 은 SIGTERM 시 1 로 종료. exit code 1 로 script 종료 방지.
    handle_sigint() {
      trap - INT
      log INFO "Received SIGINT (Ctrl-C)"
      exit 130  # 128 + 2
    }

    handle_sigterm() {
      trap - TERM
      log INFO "Received SIGTERM"
      exit 143  # 128 + 15
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
      trap cleanup_lock EXIT ERR
      trap handle_sigint INT
      trap handle_sigterm TERM

      acquire_lock "$LOCKFILE" fd

      log INFO "Starting btrfs scrub on target: $TARGET"
      ${lib.escapeShellArgs (
        lib.flatten [
          "btrfs"
          "scrub"
          "start"
          "-B"
          (lib.lists.optionals isIOPrioClassIdleSupported [
            "-c"
            "3" # idle class
          ])
          (lib.lists.optionals (!isIOPrioClassIdleSupported) [
            "-n"
            "7"
          ])
          target
        ]
      )}
    }

    main
  '';
in
{
  systemd =
    let
      description = "Run btrfs scrub on /nix";
      documentation = [
        "man:btrfs-scrub(8)"
      ];
    in
    {
      services.${serviceName} = rec {
        inherit description documentation;

        # scrub prevents suspend2ram or proper shutdown
        conflicts = [
          "shutdown.target"
          "sleep.target"
        ];
        wants = [
          "btrfs-scrub-limit.service"
        ];
        requires = [
          "local-fs.target"
        ];
        after = lib.flatten [
          wants
          requires
          "multi-user.target"
        ];
        before = conflicts;

        serviceConfig = {
          Type = "simple"; # Scrub is long-running operations

          # 커널 스케쥴링
          Nice = 19;
          IOSchedulingClass = "idle";

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
            # 26일 간격으로 수행 (년 14회)
            "*-01-01 02:55:00"
            "*-01-27 02:55:00"
            "*-02-22 02:55:00"
            "*-03-20 02:55:00" # 여기서 26.25 일 (2/22 → 3/20)
            "*-04-15 02:55:00"
            "*-05-11 02:55:00"
            "*-06-06 02:55:00"
            "*-07-02 02:55:00"
            "*-07-28 02:55:00"
            "*-08-23 02:55:00"
            "*-09-19 02:55:00" # 여기서 27일 (8/23 -> 9/19)
            "*-10-15 02:55:00"
            "*-11-10 02:55:00"
            "*-12-06 02:55:00"
          ];
          RandomizedDelaySec = "5m";
          Persistent = "true";
        };

        wantedBy = [ "timers.target" ];
        after = [ "multi-user.target" ];
      };
    };
}
