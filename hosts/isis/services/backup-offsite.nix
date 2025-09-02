/*
  NOTE:
    /secrets/rustic-onedrive/rustic.toml 에 작동하는 설정 파일이 있음.
*/

{
  self,
  pkgs,
  lib,
  ...
}:
let
  DATASET = "isis/safe/home/hnjae";
  PROFILE = "/secrets/rustic-onedrive/rustic";

  ignoreFile = self.shraed.lib.rusticIgnoreFileFactory pkgs;
  backupOffsite =
    lib.customisation.overrideDerivation
      (pkgs.writeShellApplication {
        name = "backup-offsite";

        runtimeInputs = with pkgs; [
          konsave
          util-linux
          coreutils # date
          rustic
          rclone
          inetutils # ping
          sudo
          self.packages.${pkgs.system}.rustic-zfs
        ];

        text = ''
          PROFILE='${PROFILE}'

          check_cond() {
            if [ "$UID" != 0 ]; then
              echo "[ERROR] This script must be run as root." >&2
              exit 1
            fi

            if [ ! -f "$PROFILE.toml" ]; then
              echo "[ERROR] $PROFILE.toml does not exists." >&2
              exit 1
            fi

            # if ! ping -c 1 1.1.1.1 >/dev/null 2>&1; then
            #   echo "No Internet connection." >&2
            #   exit 0 # 따로 Alert를 띄우지 않기 위해 0 으로 종료
            # fi
          }

          backup_kde() {
            export RCLONE_MULTI_THREAD_STREAMS=0 # defaults : 4
            export RUSTIC_DRY_RUN=false
            export RUSTIC_REPO_OPT_TIMEOUT="10min"
            export RUSTIC_USE_PROFILE="$PROFILE"
            export RCLONE_VERBOSE=1
            export RUSTIC_LOG_LEVEL=info
            export RUSTIC_NO_PROGRESS=true

            local id_
            local file_

            id_=$(uuidgen --time-v7)
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

          main() {
            check_cond
            backup_kde
            rustic-zfs -k -c '${ignoreFile}' -p "$PROFILE" -- '${DATASET}'
          }


          main
        '';
      })
      (_: {
        preferLocalBuild = true;
      });
in
{
  environment.systemPackages = [
    backupOffsite
    pkgs.rustic
    pkgs.rclone
    pkgs.just
  ];

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
          AccuracySec = "1m";
          # OnCalendar = "*-*-* 00:00:00";
          OnStartupSec = "15m";
          OnUnitInactiveSec = "90m";
          Persistent = false; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.
          WakeSystem = false;
        };
      };

      services."${serviceName}" = {
        inherit documentation description;

        unitConfig = rec {
          ConditionACPower = true;
          After = Wants;
          Before = [ "backup-onsite.service" ];
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
          CPUQuota = "120%";
          # IOWeight = "10";
          # MemoryHigh = "4G";

          ExecStart = [
            "${backupOffsite}/bin/backup-offsite"
          ];

          ExecCondition = lib.flatten [
            (pkgs.writeScript "${serviceName}-check-other-instance" ''
              #!${pkgs.dash}/bin/dash

              set -eu

              PATH="${
                lib.makeBinPath [
                  # pkgs.coreutils # date
                  pkgs.procps
                ]
              }"

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

            "${self.packages.${pkgs.system}.check-metered}"

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
