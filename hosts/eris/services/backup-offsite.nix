/*
  NOTE:
    /secrets/rustic-onedrive/rustic.toml 에 작동하는 설정 파일이 있음.
*/

{
  self,
  pkgs,
  lib,
  config,
  ...
}:
let
  PROFILE = "/secrets/rustic-onedrive/rustic";

  backupOffsite = pkgs.writeShellApplication {
    name = "backup-offsite";

    runtimeInputs = with pkgs; [
      util-linux # flock
      coreutils # date
      inetutils # ping
      self.packages.${pkgs.system}.rustic-zfs
    ];

    text = ''
      set -Eeuo pipefail

      readonly LOCK_TIMEOUT="3600"
      readonly LOCKFILE_1="/var/lock/rustic-onedrive.lock" # rustic-onedrive lock
      readonly LOCKFILE_2="/var/lock/zpool-eris.lock" # eris pool lock

      readonly PROFILE='${PROFILE}'

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
        release_lock "$LOCKFILE_2" fd_2
        release_lock "$LOCKFILE_1" fd_1

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
        if [ "''${EUID:-$UID}" != 0 ]; then
          log ERROR "This script must be run as root"
          exit 1
        fi

        if [ ! -f "$PROFILE.toml" ]; then
          log ERROR "$PROFILE.toml does not exists"
          exit 1
        fi

        if ! ping -c 1 -W 5 1.1.1.1 >/dev/null 2>&1; then
          log INFO "No Internet connection"
          exit 1 # eris 는 항상 인터넷에 연결되어 있어야 함.
        fi

        if ! ping -c 1 -W 5 'onedrive.live.com' >/dev/null 2>&1; then
          log WARN "Cannot connect to 'onedrive.live.com'. Skipping backup"
          # onedrive 쪽 이슈
          exit 75 # EX_TEMPFAIL (Temporaryfailure,  indicating something that is not really an error.)
        fi
      }

      main() {
        check_cond

        trap cleanup_lock EXIT INT TERM ERR
        acquire_lock "$LOCKFILE_1" fd_1
        acquire_lock "$LOCKFILE_2" fd_2

        # # 각 원소는 "공백으로 구분된 데이터셋 묶음"
        # local -a dataset_groups=(
        #   "eris/safe/storage/music"
        #   "eris/safe/storage/vault"
        #   "eris/safe/apps/readeck/postgresql eris/safe/apps/readeck/readeck"
        # )
        #
        # local group
        # for group in "''${dataset_groups[@]}"; do
        #   # group 문자열을 공백 단위로 배열로 분해
        #   local -a ds
        #   read -r -a ds <<< "$group"
        #
        #   log INFO "Running rustic-zfs for dataset(s): ''${ds[*]}"
        #   rustic-zfs -k -p "$PROFILE" --  "''${ds[@]}"
        # done
        rustic-zfs -k -p "$PROFILE" -- eris/safe/storage/music
        rustic-zfs -k -p "$PROFILE" -- eris/safe/storage/vault

        rustic-zfs -k -p "$PROFILE" -- eris/safe/apps/garage/meta eris/safe/apps/garage/data eris/safe/apps/postgresql

        rustic-zfs -k -p "$PROFILE" -- eris/safe/apps/freshrss/postgresql eris/safe/apps/freshrss/freshrss
        rustic-zfs -k -p "$PROFILE" -- eris/safe/apps/readeck/postgresql eris/safe/apps/readeck/readeck
      }

      main
    '';
  };
in
{
  # environment.systemPackages = [ backupOffsite ];

  systemd =
    let
      serviceName = "backup-offsite";
      documentation = [
        "https://github.com/rustic-rs/rustic/blob/main/config/README.md"
        "https://github.com/rustic-rs/rustic/blob/main/config/full.toml"
        "https://rustic.cli.rs/docs/commands/init/intro.html"
        "https://rustic.cli.rs/docs/commands/backup/intro.html"
      ];
      description = "Rustic off-site backup";
    in
    {
      timers."${serviceName}" = {
        inherit documentation description;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          # OnCalendar = "*-*-* 00:00:00";
          OnStartupSec = "540m";
          OnUnitInactiveSec = "1080m"; # 18h
          RandomizedDelaySec = "54m";
          Persistent = false; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.
          WakeSystem = false;
        };
      };

      services."${serviceName}" = {
        inherit documentation description;

        unitConfig = rec {
          ConditionACPower = true;
          After = Wants;
          Wants = [ "network-online.target" ];
        };

        serviceConfig = {
          Type = "oneshot";
          PrivateTmp = true;

          # 커널 스케쥴링
          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";

          # systemd.resourced (cgroup)
          CPUWeight = "idle";
          CPUQuota = "400%";
          MemoryHigh = "16G";
          MemoryMax = "20G";
          IOWeight = "10"; # default 100

          ExecStart = [ "${backupOffsite}/bin/backup-offsite" ];
        };
      };
    };
}
