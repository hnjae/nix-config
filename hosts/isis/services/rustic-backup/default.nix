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

  ignoreFile = pkgs.writeText "ignore.txt" ''
    /.*
    /Downloads
    /dwhelper
    /git
    /temp

    !/.var
    !/.var/app
    /.var/app/*/.ld.so
    /.var/app/*/cache

    /.var/app/*/config/*[Cc]ache
    /.var/app/*/config/**/*[Cc]ache
    /.var/app/*/config/**/CacheStorage
    /.var/app/*/data/*[Cc]ache
    /.var/app/*/data/**/*[Cc]ache

    /.var/app/*/config/fcitx
    /.var/app/*/config/ibus
    /.var/app/*/config/pulse/cookie
    /.var/app/*/config/trashrc
    /.var/app/*/config/user-dirs.dirs
    /.var/app/*/data/recently-used.xbel
    /.var/app/*/data/user-places.xbel*

    /.var/app/com.usebottles.bottles/data/bottles/bottles/*/drive_c/users/*/AppData/Local/Temp
    /.var/app/org.kde.ark/data/ark/ark_recentfiles
    /.var/app/org.kde.dolphin/config/session
    /.var/app/org.kde.gwenview/data/gwenview/recentfolders
    # /.var/app/org.kde.kontact/data/akonadi_*/*/tmp
    /.var/app/org.kde.kontact/data/kontact/kontact_recentfiles
    /.var/app/org.kde.kwrite/data/kwrite/anonymous.katesession
    /.var/app/org.kde.kwrite/data/kwrite/sessions
    /.var/app/org.kde.okular/data/okular/docdata
    /.var/app/org.libreoffice.LibreOffice/config/libreoffice/4/user/backup
    /.var/app/org.libreoffice.LibreOffice/config/libreoffice/4/user/extensions/tmp
    /.var/app/org.onlyoffice.desktopeditors/data/onlyoffice/desktopeditors/recents.xml

    !/.mozilla
    /.mozilla/firefox/Crash Reports
    /.mozilla/firefox/firefox-mpris
    /.mozilla/firefox/*/datareporting
    /.mozilla/firefox/*/saved-telemetry-pings
    /.mozilla/firefox/*/storage/default/*/cache
    /.mozilla/firefox/*/weave/logs
    /.mozilla/firefox/*/sessionstore-backups
    !/.config
    /.config/*
    !/.config/chromium
    /.config/chromium/**/*[Cc]ache
    /.config/chromium/*[Cc]ache
    /.config/chromium/**/CacheStorage
    !/.cert

    # Linux
    .Trash-*
    .nfs*
    .fuse_hidden*
    .snapshots

    # KDE
    .directory

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
    *.part
    *.crdownload

    # Vim
    *.swp

    # KdenLive
    # kdenlive/**/proxy
    # kdenlive/**/audiothumbs
    # kdenlive/**/preview
    # kdenlive/**/sequences
    # kdenlive/**/videothumbs
    # kdenlive/**/workfiles

    # Direnv
    .direnv

    # NodeJS
    node_modules

    # Python (NO CACHEDIR.TAG inside)
    .venv
    __pycache__
    *.py[oc]

    # ZSH
    *.zwc

    # Things should be excluded by .gitignore
    # dist
    # build

    # vi:ft=gitignore
  '';

  backupIsis = (
    pkgs.writeScriptBin "backup-isis" ''
      #!${pkgs.dash}/bin/dash

      set -eu

      ${lib.escapeShellArgs [
        self.apps.${pkgs.system}.rustic-zfs.program
        "-k"
        "-i"
        ignoreFile
        "-p"
        PROFILE
        "--"
        DATASET
      ]}
    ''
  );

  backupKde =
    lib.customisation.overrideDerivation
      (pkgs.writeShellApplication {
        name = "backup-kde";

        runtimeInputs = with pkgs; [
          konsave
          util-linux
          uutils-coreutils-noprefix # date
          rustic
          rclone
          inetutils # ping
          sudo
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

            if ! ping -c 1 1.1.1.1 >/dev/null 2>&1; then
              echo "No Internet connection." >&2
              exit 0 # 따로 Alert를 띄우지 않기 위해 0 으로 종료
            fi
          }

          main() {
            check_cond

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

          main
        '';
      })
      (_: {
        preferLocalBuild = true;
      });
in
{
  environment.systemPackages = [
    backupIsis
    backupKde
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
          CPUQuota = "120%";
          # IOWeight = "10";
          # MemoryHigh = "4G";

          ExecStart = [
            "${backupKde}/bin/backup-kde"
            "${backupIsis}/bin/backup-isis"
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
