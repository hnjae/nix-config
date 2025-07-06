/*
  NOTE:
    /secrets/rustic-onedrive/rustic.toml 에 작동하는 설정 파일이 있음.
*/

{ pkgs, lib, ... }:
let
  DATASET_ = "isis/safe/home/hnjae";
  MOUNTPOINT_ = "/home/hnjae";
  PROFILE_ = "/secrets/rustic-onedrive/rustic";

  ignoreFile = pkgs.writeText "ignore.txt" ''
    /.*
    /git
    /Downloads
    !/.var
    /.var/**/.ld.so
    /.var/**/cache
    /.var/**/config/**/*[Cc]ache
    /.var/**/config/*[Cc]ache
    /.var/**/config/pluse/cookie
    /.var/**/data/*.bak
    /.var/**/data/*.tbcache
    /.var/**/data/recently-used.xbel
    !/.mozilla
    /.mozilla/firefox/**/storage/default/**/cache
    !/.config/chromium
    /.config/chromium/**/*[Cc]ache
    /.config/chromium/*[Cc]ache

    # Linux
    .directory
    .Trash-*
    .nfs*
    .fuse_hidden*
    .snapshots

    # macOS
    .DS_Store
    ._*
    .localized

    # MS Windows
    [Tt]humbs.db
    [Dd]esktop.ini
    ?RECYCLE.BIN

    # Android
    .temp
    .thumbnails
    .trashed-*

    # Temporary files
    *.parts
    *.crdownload

    # vim
    tags
    *.swp
    *~

    # KdenLive
    # kdenlive/**/proxy
    # kdenlive/**/audiothumbs
    # kdenlive/**/preview
    # kdenlive/**/sequences
    # kdenlive/**/videothumbs
    # kdenlive/**/workfiles

    # Misc
    .cache
    .direnv

    # NodeJS
    dist
    node_modules

    # Python
    .venv
    __pycache__
    *.py[oc]
    build

    # vi:ft=gitignore
  '';

  rusticBackupIsis = pkgs.writeShellApplication {
    name = "rustic-backup-isis";
    runtimeInputs = with pkgs; [
      rustic
      rclone
      uutils-coreutils-noprefix # date,
      inetutils # ping
      procps # pgrep
      jq
    ];

    text = ''
      set -euo pipefail

      DATASET='${DATASET_}'
      MOUNTPOINT='${MOUNTPOINT_}'
      ZFS_CMD='/run/booted-system/sw/bin/zfs'
      PROFILE='${PROFILE_}'

      check_cond() {
        if [ "$UID" != 0 ]; then
          echo "[ERROR] This script must be run as root." >&2
          exit 1
        fi

        if [ ! -f "$ZFS_CMD" ]; then
          echo "[ERROR] $ZFS_CMD does not exists." >&2
          exit 1
        fi

        if [ ! -f "$PROFILE.toml" ]; then
          echo "[ERROR] $PROFILE.toml does not exists." >&2
          exit 1
        fi

        if pgrep --exact '(restic)|(rustic)' >/dev/null 2>&1; then
          echo "Another restic(rustic) instance is running."
          exit 0 # 따로 Alert를 띄우지 않기 위해 0 으로 종료
        fi

        if ! ping -c 1 1.1.1.1 >/dev/null 2>&1; then
          echo "No Internet connection." >&2
          exit 0 # 따로 Alert를 띄우지 않기 위해 0 으로 종료
        fi
      }

      cleanup_snapshots() {
        "$ZFS_CMD" list -t snapshot --json "$DATASET" | jq -r '
          .datasets[]? |
          select(.snapshot_name | startswith("rustic_")) |
          .name
        ' | while IFS= read -r line; do
          if "$ZFS_CMD" destroy -- "$line"; then
            echo "[INFO] Destroyed ZFS snapshot: $line" >&2
          else
            echo "[ERROR] Failed to destroy ZFS snapshot: $line" >&2
            exit 1
          fi
        done
      }

      main() {
        check_cond
        cleanup_snapshots

        export RCLONE_MULTI_THREAD_STREAMS=2 # defaults : 4
        export RUSTIC_DRY_RUN=false
        export RUSTIC_REPO_OPT_TIMEOUT="10min"
        export RUSTIC_USE_PROFILE="$PROFILE"

        if [ "$TERM" = "dumb" ]; then
          export RCLONE_VERBOSE=1
          export RUSTIC_LOG_LEVEL=info
          export RUSTIC_NO_PROGRESS=true
        else
          # Running in interactive shell
          export RCLONE_VERBOSE=1
          export RUSTIC_LOG_LEVEL=info
          export RUSTIC_NO_PROGRESS=false
        fi

        local time_
        local snapshot_dir
        local snapshot_name
        local snapshot_dataset

        time_="$(date --utc '+%Y-%m-%dT%H:%M:%SZ')"
        snapshot_name="rustic_''${time_}"
        snapshot_dataset="''${DATASET}@''${snapshot_name}"

        "$ZFS_CMD" snapshot -r "$snapshot_dataset" &&
          echo "[INFO] Created ZFS snapshot: $snapshot_dataset" >&2

        snapshot_dir="''${MOUNTPOINT}/.zfs/snapshot/''${snapshot_name}"

        [ -d "$snapshot_dir" ] && rustic backup \
          --one-file-system \
          --no-scan \
          --long \
          --git-ignore \
          --no-require-git \
          --exclude-if-present "CACHEDIR.TAG" \
          --label 'isis' \
          --time "$time_" \
          --custom-ignorefile '${ignoreFile}' \
          --as-path "$MOUNTPOINT" \
          -- "$snapshot_dir"

        "$ZFS_CMD" destroy "$snapshot_dataset" &&
          echo "[INFO] Destroyed ZFS snapshot: $snapshot_dataset" >&2
      }

      main
    '';
  };

  rusticBackupKde = pkgs.writeShellApplication {
    name = "rustic-backup-kde";

    runtimeInputs = with pkgs; [
      konsave
      uuid7
      uutils-coreutils-noprefix # date,
      rustic
      rclone
      inetutils # ping
    ];

    text = ''
      check_cond() {
        if [ "$UID" != 0 ]; then
          echo "[ERROR] This script must be run as root." >&2
          exit 1
        fi

        if ! ping -c 1 1.1.1.1 >/dev/null 2>&1; then
          echo "No Internet connection." >&2
          exit 0 # 따로 Alert를 띄우지 않기 위해 0 으로 종료
        fi
      }

      main() {
        check_cond

        PROFILE='${PROFILE_}'

        export RCLONE_MULTI_THREAD_STREAMS=0 # defaults : 4
        export RUSTIC_DRY_RUN=false
        export RUSTIC_REPO_OPT_TIMEOUT="10min"
        export RUSTIC_USE_PROFILE="$PROFILE"

        if [ "$TERM" = "dumb" ]; then
          export RCLONE_VERBOSE=1
          export RUSTIC_LOG_LEVEL=info
          export RUSTIC_NO_PROGRESS=true
        else
          # Running in interactive shell
          export RCLONE_VERBOSE=1
          export RUSTIC_LOG_LEVEL=info
          export RUSTIC_NO_PROGRESS=false
        fi

        local id_
        local file_

        id_=$(uuid7)
        file_="/tmp/''${id_}.knsv"

        # Cleanup existing konsave profile if exists
        [ -f "$file_" ] && rm "$file_"

        time_="$(date --utc '+%Y-%m-%dT%H:%M:%SZ')"
        sudo -u hnjae konsave --save "$id_"
        sudo -u hnjae konsave --export-profile "$id_" --export-directory /tmp &&
          echo "[INFO] konsave profile exported to $file_" >&2
        sudo -u hnjae konsave --remove "$id_"

        rustic backup \
          --long \
          --label "isis-kde.knsv" \
          --time "$time_" \
          --stdin-filename "isis-kde.knsv" \
          "-" < "$file_"

        rm "$file_" &&
          echo "[INFO] Cleaned up $file_" >&2
      }

      main
    '';
  };
in
{
  environment.systemPackages = [
    rusticBackupIsis
    rusticBackupKde
    pkgs.rustic
    pkgs.rclone
    pkgs.just
  ];

  systemd =
    let
      serviceName = "rustic-backup";
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
          AccuracySec = "1m";
          # OnCalendar = "*-*-* 00:00:00";
          OnStartupSec = "15m";
          OnUnitInactiveSec = "120m";
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
          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";
          Nice = 19;

          # systemd.resourced (cgroup)
          CPUWeight = "idle";
          CPUQuota = "160%";
          # IOWeight = "10";
          # MemoryHigh = "4G";

          # ExecStopPost = pkgs.writeScript "cleanup-zfs-snapshots" ''
          #   #!${pkgs.dash}/bin/dash
          #
          #   set -eu
          #
          #   PATH="${pkgs.jq}/bin"
          #   DATASET='${DATASET}'
          #   ZFS_CMD='/run/booted-system/sw/bin/zfs'
          #
          #   cleanup_snapshots() {
          #     "$ZFS_CMD" list -t snapshot --json "$DATASET" | jq -r '
          #       .datasets[]? |
          #       select(.snapshot_name | startswith("rustic_")) |
          #       .name
          #     ' | while IFS= read -r line; do
          #       if "$ZFS_CMD" destroy -- "$line"; then
          #         echo "[INFO] Destroyed ZFS snapshot: $line" >&2
          #       else
          #         echo "[ERROR] Failed to destroy ZFS snapshot: $line" >&2
          #         exit 1
          #       fi
          #     done
          #
          #     cleanup_snapshots
          #   }
          # '';

          ExecStart = [
            "${rusticBackupKde}/bin/rustic-backup-kde"
            "${rusticBackupIsis}/bin/rustic-backup-isis"
          ];

          ExecCondition = lib.flatten [
            (pkgs.writeScript "${serviceName}-check-other-instance" ''
              #!${pkgs.dash}/bin/dash

              set -eu

              PATH="${pkgs.procps}/bin"

              if pgrep --exact '(restic)|(rustic)|(zfs)|(rclone)|(rsync)' >/dev/null 2>&1; then
                echo "Another I/O-intensive instance is running."
                exit 1
              fi

              exit 0
            '')

            (pkgs.writeScript "${serviceName}-check-vpn-route" ''
              #!${pkgs.dash}/bin/dash

              set -eu

              PATH="${pkgs.iproute2}/bin:${pkgs.gnugrep}/bin"

              if ip route show default | grep -E "dev (tun|ppp)" >/dev/null 2>&1; then
                echo "Network is routed to VPN."
                exit 1
              fi

              exit 0
            '')

            (
              (pkgs.writeScript "${serviceName}-check-metered-connection" (
                lib.concatLines [
                  ''
                    #!${pkgs.nushell}/bin/nu

                    $env.PATH = [
                      '${pkgs.networkmanager}/bin'
                    ]
                  ''
                  (builtins.readFile ./resources/check-metered.nu)
                ]
              ))
            )

            (pkgs.writeScript "${serviceName}-check-internet" ''
              #!${pkgs.dash}/bin/dash

              set -eu

              PATH="${pkgs.inetutils}/bin"

              if ! ping -c 1 'https://onedrive.live.com' >/dev/null 2>&1; then
                echo "Cannot connect to 'onedrive.live.com'."
                exit 1
              fi

              exit 0
            '')
          ];
        };
      };
    };
}
