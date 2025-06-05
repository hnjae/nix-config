/*
  NOTE:
    /secrets/rustic-onedrive/rustic.toml 에 작동하는 설정 파일이 있음.
*/

{ pkgs, lib, ... }:
{
  environment.defaultPackages = with pkgs; [
    rustic
    rclone
    just
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

      # workingDirectory = "/secrets/rustic-onedrive";
      profile = "/secrets/rustic-onedrive/rustic";
    in
    {
      timers."${serviceName}" = {
        inherit documentation description;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          AccuracySec = "1m";
          # OnCalendar = "*-*-* 00:00:00";
          OnStartupSec = "15m";
          OnUnitInactiveSec = "60m";
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

        path = with pkgs; [ rclone ];

        serviceConfig = {
          Type = "oneshot";

          PrivateTmp = true;
          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";

          # systemd.resourced (cgroup)
          CPUWeight = "idle";
          IOWeight = "10";
          # MemoryHigh = "4G";
          # CPUQuota = "45%";
          AllowedCPUs = "0";
          # NOTE: 이래도 CPU Fan 은 돌아감.. <2025-03-05>

          ExecStart = [
            (pkgs.writeScript "${serviceName}-start" ''
              #!${pkgs.dash}/bin/dash

              set -eu

              if [ ! -f "${profile}.toml" ]; then
                echo "ERROR: ${profile}.toml does not exists."
                exit 1
              fi
            '')
            (lib.escapeShellArgs [
              "${pkgs.rustic}/bin/rustic"
              "backup"
              "--no-progress"
              "--log-level=info"
              "--use-profile=${profile}"
            ])
          ];
          ExecCondition = lib.flatten [
            (pkgs.writeScript "${serviceName}-check-other-instance" ''
              #!${pkgs.dash}/bin/dash

              set -eu

              PATH="${pkgs.procps}/bin"

              if pgrep 'restic|rustic' >/dev/null 2>&1; then
                echo "Another restic(rustic) instance is running."
                exit 1
              fi

              if pgrep 'zfs|rclone|rsync' >/dev/null 2>&1; then
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
