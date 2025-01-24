{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.base-nixos;
  isDesktop = cfg.role == "desktop";
  inherit (lib) mkOverride;
in {
  config = lib.mkIf (cfg.hostType == "baremetal") {
    # NOTE: NTPD vs chronyd <2023-12-20>
    # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite#sect-differences_between_ntpd_and_chronyd

    services.chrony = {
      enable = mkOverride 999 true;
      serverOption =
        if isDesktop
        then "offline"
        else "iburst";
      enableNTS = true;
      servers =
        if config.services.chrony.enableNTS
        then [
          # https://github.com/jauderho/nts-servers
          "time.cloudflare.com" # anycast
          "nts.netnod.se" # anycast
          "oregon.time.system76.com"
          "paris.time.system76.com"
          # "brazil.time.system76.com"
        ]
        else [
          "time.cloudflare.com"
          "0.pool.ntp.org"
          "1.pool.ntp.org"
          "2.pool.ntp.org"
          # "3.pool.ntp.org"
        ];
    };

    networking.networkmanager.dispatcherScripts =
      lib.lists.optionals (
        isDesktop
        && config.services.chrony.enable
      ) [
        {
          # following code follows following license: https://aur.archlinux.org/cgit/aur.git/tree/LICENSE?h=networkmanager-dispatcher-chrony
          source = pkgs.writeText "chrony" ''
            #!/bin/sh

            INTERFACE="$1"
            STATUS="$2"

            # Make sure we're always getting the standard response strings
            LANG='C'

            chrony_cmd() {
              echo "Chrony going $1."
              exec "${pkgs.chrony}/bin/chronyc" -a "$1"
            }

            nm_connected() {
              [ "$(${pkgs.networkmanager}/bin/nmcli -t --fields STATE g)" = 'connected' ]
            }

            case "$STATUS" in
              up)
                chrony_cmd online
              ;;
              vpn-up)
                chrony_cmd online
              ;;
              down)
                # Check for active interface, take offline if none is active
                nm_connected || chrony_cmd offline
              ;;
              vpn-down)
                # Check for active interface, take offline if none is active
                nm_connected || chrony_cmd offline
              ;;
            esac
          '';
          type = "basic";
        }
      ];

    # disable timesyncd
    services.timesyncd.enable = mkOverride 999 (!config.services.chrony.enable);
  };
}
