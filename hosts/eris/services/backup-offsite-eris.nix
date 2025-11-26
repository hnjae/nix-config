/*
  NOTE:
    /secrets/rustic-onedrive/rustic.toml 에 작동하는 설정 파일이 있음.
*/

{
  self,
  pkgs,
  config,
  ...
}:
let
  serviceName = "backup-offsite-eris";

  script = pkgs.writeShellApplication {
    name = serviceName;

    runtimeInputs = with pkgs; [
      util-linux # flock
      coreutils # date
      inetutils # ping
      podman
      self.packages.${pkgs.system}.rustic-zfs
    ];

    text = ''
      set -Eeuo pipefail

      log() { printf '[%s] %s\n' "$1" "$2" >&2; }

      if [ "''${EUID:-$UID}" != 0 ]; then
        log ERROR "This script must be run as root"
        exit 1
      fi

      if [ ! -f "${config.sops.secrets."env-restic-onedrive".path}" ]; then
        log ERROR "Secrets file not found: ${config.sops.secrets."env-restic-onedrive".path}"
        exit 1
      fi

      # set -a: 이후 설정되는 모든 변수를 자동으로 export
      set -a
      # https://www.shellcheck.net/wiki/SC1091
      # shellcheck source=/dev/null
      source "${config.sops.secrets."env-restic-onedrive".path}"
      set +a

      PATH="''${PATH}:/run/booted-system/sw/bin" # podman 등에서 zfs 명령어를 찾을수 있도록 함.
      readonly LOCK_TIMEOUT="3600"
      readonly LOCKFILE_1="/var/lock/restic-onedrive.lock" # restic-onedrive lock
      readonly LOCKFILE_2="/var/lock/zpool-eris.lock" # eris pool lock


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
          log ERROR "Cannot create lock file: $lock'"
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

      check_cond() {
        if [ "''${RUSTIC_USE_PROFILE:-}" = "" ] && [ "''${RUSTIC_REPOSITORY:-}" = "" ]; then
          log ERROR "Either RUSTIC_USE_PROFILE or RUSTIC_REPOSITORY environment variable must be set"
          exit 1
        fi

        if [ "''${RUSTIC_USE_PROFILE:-}" != "" ] && [ ! -f "$RUSTIC_USE_PROFILE.toml" ]; then
          log ERROR "$RUSTIC_USE_PROFILE.toml does not exists"
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

        set +e
        if [ -d "/srv/nfs/vault/Pictures" ]; then
          rustic backup --no-progress --one-file-system --no-scan --log-level info --ignore-devid --group-by "host,paths" --long -- '/srv/nfs/vault/Pictures'
        else
          log ERROR "/srv/nfs/vault/Pictures does not exists. Skipping..."
        fi

        if [ -d "/srv/nfs/vault/Library" ]; then
          rustic backup --no-progress --one-file-system --no-scan --log-level info --ignore-devid --group-by "host,paths" --long -- '/srv/nfs/vault/Library'
        else
          log ERROR "/srv/nfs/vault/Library does not exists. Skipping..."
        fi

        # Shared resources
        rustic-zfs -- eris/safe/apps/garage/meta eris/safe/apps/garage/data eris/safe/apps/postgresql
        rustic-zfs -- eris/safe/apps/freshrss/postgresql eris/safe/apps/freshrss/freshrss
        rustic-zfs -- eris/safe/apps/iason/config eris/safe/apps/iason/resources
        rustic-zfs -- eris/safe/apps/karakeep/data eris/safe/apps/karakeep/assets

        rustic-zfs -- eris/safe/apps/navidrome/music eris/safe/apps/navidrome/data
        rustic-zfs -- eris/safe/apps/readeck/postgresql eris/safe/apps/readeck/readeck

        # GC seafile before backup
        if podman container exists -- 'seafile-app'; then
          podman exec -- 'seafile-app' '/opt/seafile/seafile-server-latest/seaf-gc.sh'
        fi

        rustic-zfs -- eris/safe/apps/seafile/data eris/safe/apps/seafile/mysql
        set -e
      }

      main
    '';
  };
in
{
  environment.defaultPackages = [ script ];

  systemd =
    let
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
          OnCalendar = "*-*-* 04:00:00";
          RandomizedDelaySec = "5m";

          # OnStartupSec = "360m";
          # OnUnitInactiveSec = "720m"; # 12h
          # RandomizedDelaySec = "36m";
          Persistent = false; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.
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
          MemoryHigh = "10G";
          MemoryMax = "12G";
          IOWeight = "10"; # default 100

          ExecStart = [ "${script}/bin/${serviceName}" ];
        };
      };
    };
}
