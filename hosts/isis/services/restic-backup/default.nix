/*
  README:
    - `/secrets/rclone.conf` 에 적절한 rclone 설정을 넣어두어야 한다.
    - `rclone.conf` 의 access_token 이 업데이트 될수 있어야 하므로, sops 로 모듈에 번들하지 않는다.

    다음의 환경에서는 백업이 수행되지 않는다.
      - 전원 연결이 되지 않은 상태
      - VPN 에 연결되어 있고, VPN 을 통해 인터넷에 연결된 상태
      - onedrive.live.com 에 접속할 수 없는 상태
      - metered network 에 연결되어 있는 상태
*/
{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  serviceName = "restic-backup-off-site";
  paths = [
    "/home/hnjae/Projects"
    "/home/hnjae/Documents"
    "/home/hnjae/Library"
    "/home/hnjae/Pictures"
  ];
in
{
  sops.secrets."restic-onedrive-repo-password" = {
    sopsFile = ./secrets/restic-onedrive-repo-password;
    format = "binary";
  };

  systemd.timers."${serviceName}" = {
    inherit (config.systemd.services."${serviceName}") documentation description;

    wantedBy = [ "timers.target" ];
    timerConfig = {
      AccuracySec = "1m";
      # OnCalendar = "*-*-* 00:00:00";
      OnStartupSec = "30m";
      OnUnitInactiveSec = "1h";
      Persistent = false; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.
      WakeSystem = false;
    };
  };

  systemd.services."${serviceName}" = {
    documentation = [ "man:restic-backup(1)" ];
    description = "Restic off-site backup";

    environment = {
      RESTIC_COMPRESSION = "auto";
      RESTIC_PACK_SIZE = builtins.toString 128;
      RESTIC_CACHE_DIR = "/var/cache/${serviceName}";
      RESTIC_PASSWORD_FILE = config.sops.secrets."restic-onedrive-repo-password".path;
      RESTIC_REPOSITORY = "rclone:onedrive:.restic";
      RESTIC_READ_CONCURRENCY = builtins.toString 1;
      RESTIC_PROGRESS_FPS = "0.02"; # update progress every 72s (1.0 == 3600s)

      # GOGC = "off";
      GOMEMLIMIT = builtins.toString (2 * 1024 * 1024 * 1024); # 2 GiB

      RCLONE_CONFIG = "/secrets/rclone.conf";
      RCLONE_BWLIMIT = "4M"; # MiB/s
    };
    serviceConfig = {
      Type = "oneshot";

      CacheDirectory = "${serviceName}";
      RuntimeDirectory = "${serviceName}";
      CacheDirectoryMode = "0700";
      PrivateTmp = true;

      # systemd.exec
      # Nice = 19;
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";

      # systemd.resourced (cgroup)
      CPUWeight = "idle";
      IOWeight = "10";
      MemoryHigh = "4G";
      CPUQuota = "50%";

      ExecCondition = lib.flatten [
        (pkgs.writeScript "${serviceName}-check-other-instance" ''
          #!${pkgs.dash}/bin/dash

          set -eu

          PATH="${pkgs.procps}/bin"

          if pgrep 'restic|rustic' >/dev/null 2>&1; then
            echo "Another restic(rustic) instance is running."
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

        (lib.lists.optional (config.networking.networkmanager.enable) (
          pkgs.writeScript "${serviceName}-check-metered-connection" (
            lib.concatLines [
              ''
                #!${pkgs.nushell}/bin/nu

                $env.PATH = [
                  '${pkgs.networkmanager}/bin'
                ]
              ''
              (builtins.readFile ./resources/check-metered.nu)
            ]
          )
        ))

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

      ExecStart =
        let
          excludeFile = pkgs.writeText "${serviceName}-exclude-file" (
            lib.concatLines self.constants.configs.resticExcludes
          );
          filesFrom = pkgs.writeText "${serviceName}-files-from" (lib.concatLines paths);
        in
        (builtins.concatStringsSep " " [
          "${pkgs.restic}/bin/restic"
          "backup"
          "--one-file-system"
          "--exclude-caches"
          "--exclude-file=${excludeFile}"
          "--files-from=${filesFrom}"
        ]);
    };

    unitConfig = {
      ConditionACPower = true;
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
  };
}
