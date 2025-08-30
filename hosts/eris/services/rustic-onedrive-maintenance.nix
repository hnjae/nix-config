let
  PROFILE = "/secrets/rustic-onedrive/rustic";
  serviceName = "rustic-onedrive-maintenance";
in
{ pkgs, lib, ... }:
let
  script = pkgs.writeShellScript "${serviceName}" ''
    set -Eeuo pipefail

    PATH="${
      lib.makeBinPath [
        pkgs.util-linux # flock
        # pkgs.coreutils # date
        pkgs.rustic
        pkgs.rclone # used in rustic
        pkgs.inetutils # ping
      ]
    }"
    readonly LOCK_TIMEOUT="3600"
    readonly LOCKFILE="/var/lock/rustic-onedrive.lock" # eris pool lock
    readonly PROFILE="${PROFILE}"

    log() { printf '[%s] %s\n' "$1" "$2" >&2; }

    release_lock() {
      local lock="$1" fdvar="$2"

      local fd="''${!fdvar-}"

      if [ "$fd" != "" ]; then
        log INFO "Releasing lock: {lock: '$lock', fd: '$fd'}"
        flock -u "$fd" 2>/dev/null || true

        # Close file descriptor $fd ( `>&-` 구문에 변수 사용이 불가하므로 eval 사용)
        eval "exec ''${fd}>&-" 2>/dev/null || true
      fi

      [ -f "$lock" ] && rm -f "$lock" 2>/dev/null
    }

    cleanup_lock() {
      # 트랩 재진입 방지
      trap - EXIT ERR INT TERM

      local rc=$?

      log INFO "Cleaning up locks"
      release_lock "$LOCKFILE" fd

      log INFO "Script finished with exit code: $rc"
      exit "$rc"
    }

    acquire_lock() {
      local lock="$1" fdvar="$2"

      if ! exec {fd}>"$lock"; then
        log ERROR "Cannot create lock file: $lock"
        exit 1
      fi

      log INFO "Acquiring lock: $lock (timeout: ''${LOCK_TIMEOUT}s)"
      if ! flock -w "$LOCK_TIMEOUT" "$fd"; then
        log ERROR "Lock not acquired for '$lock' within ''${LOCK_TIMEOUT}s"
        exit 75 # EX_TEMPFAIL (Temporaryfailure,  indicating something that is not really an error.)
      fi
      log INFO "Lock acquired: {lock: '$lock', fd: '$fd'}"

      # 호출자에게 FD 번호를 넘겨줌
      printf -v "$fdvar" '%s' "$fd"
    }

    check_cond() {
      # if [ "''${EUID:-$UID}" != 0 ]; then
      #   log ERROR "This script must be run as root"
      #   exit 1
      # fi

      if [ ! -f "$PROFILE.toml" ]; then
        log ERROR "$PROFILE.toml does not exists"
        exit 1
      fi

      if ! ping -c 1 -W 5 1.1.1.1 >/dev/null 2>&1; then
        log INFO "No Internet connection"
        exit 1 # eris 는 항상 인터넷에 연결되어 있어야 함.
      fi

      if ! ping -c 1 -W 5 'onedrive.live.com' >/dev/null 2>&1; then
        log WARN "Cannot connect to 'onedrive.live.com'. Skipping..."
        # onedrive 쪽 이슈
        exit 75 # EX_TEMPFAIL (Temporaryfailure,  indicating something that is not really an error.)
      fi
    }

    main() {
      check_cond

      trap cleanup_lock EXIT INT TERM ERR
      acquire_lock "$LOCKFILE" fd

      rustic forget --use-profile='${PROFILE}' --log-level=info --no-progress

      # max-repack 805MiB 에서 갑자기 저속 걸림. 1.21 GiB 에서 timeout 발생 2025-07-25
      rustic prune --use-profile='${PROFILE}' --log-level=info --no-progress --max-unused=100MiB --max-repack=500MiB

      # TODO: run scrub (check --read-data) <2025-08-30>
    }

    main
  '';
in
{

  systemd =
    let
      documentation = [
        "https://github.com/rustic-rs/rustic/blob/main/config/README.md"
        "https://github.com/rustic-rs/rustic/blob/main/config/full.toml"
        "https://rustic.cli.rs/docs/commands/init/intro.html"
      ];
      description = "Run maintenance of rustic-onedrive repository";
    in
    {
      timers."${serviceName}" = {
        inherit documentation description;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 02:00:00";
          RandomizedDelaySec = "5m";
        };
      };

      services."${serviceName}" = {
        inherit documentation description;

        unitConfig = rec {
          After = Wants;
          Wants = [ "network-online.target" ];
        };

        path = with pkgs; [ rclone ];

        serviceConfig = {
          Type = "oneshot";

          # WIP: hardening 아래 다 키면 rclone.conf 업데이트가 안됨.
          PrivateTmp = true;
          # NoNewPrivileges = true;
          # ProtectSystem = "strict";
          # # CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_DAC_READ_SEARCH
          # RestrictNamespaces = true;
          # ProtectKernelTunables = true;
          # ProtectKernelModules = true;
          # ProtectControlGroups = true;
          # PrivateDevices = true;
          # RestrictSUIDSGID = true;

          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";
          ExecStart = script;
        };
      };
    };
}
