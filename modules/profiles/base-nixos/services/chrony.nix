{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.base-nixos;
  isDesktop = cfg.role == "desktop";
  inherit (lib) mkOverride;
in
{
  config = lib.mkIf (cfg.hostType == "baremetal") {
    # NOTE: NTPD vs chronyd <2023-12-20>
    # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite#sect-differences_between_ntpd_and_chronyd

    services.chrony = {
      enable = mkOverride 999 true;
      serverOption = if isDesktop then "offline" else "iburst"; # nix module 이 iburst 와 offline 을 동시에 넣는 걸 지원 하지 않음. <NixOS 25.05>
      enableNTS = true;
      servers =
        if config.services.chrony.enableNTS then
          [
            # https://github.com/jauderho/nts-servers
            "time.cloudflare.com" # anycast
            # "nts.netnod.se" # anycast
            "oregon.time.system76.com"
            # "ohio.time.system76.com"
            "virginia.time.system76.com"
            "paris.time.system76.com"
            "brazil.time.system76.com"
          ]
        else
          [
            "time.cloudflare.com"
            "0.pool.ntp.org"
            "1.pool.ntp.org"
            "2.pool.ntp.org"
            "3.pool.ntp.org"
          ];
    };

    networking.networkmanager.dispatcherScripts =
      lib.lists.optional (isDesktop && config.services.chrony.enable)
        {
          type = "basic";
          # following code follows following license: https://aur.archlinux.org/cgit/aur.git/tree/LICENSE?h=networkmanager-dispatcher-chrony
          source = pkgs.writeScript "chrony" ''
            #!${pkgs.dash}/bin/dash

            set -eu

            PATH="${
              lib.makeBinPath [
                pkgs.chrony
                pkgs.networkmanager
              ]
            }"

            INTERFACE="$1"
            STATUS="$2"

            # Make sure we're always getting the standard response strings
            LANG='C'

            chrony_cmd() {
              echo "Chrony going $1." >&2
              exec "chronyc" -a "$1"
            }

            nm_connected() {
              [ "$(nmcli networking connectivity check)" = 'full' ]
            }

            if [ "$INTERFACE" = "lo" ]; then
              # Local interface
              exit 0
            fi

            case "$STATUS" in
              up|vpn-up)
                # Check for full connectivity, take online if connected
                nm_connected && chrony_cmd online
              ;;
              down|vpn-down)
                # Check for full connectivity, take offline if not connected
                nm_connected || chrony_cmd offline
              ;;
            esac
          '';
        };

    # disable timesyncd
    services.timesyncd.enable = mkOverride 999 (!config.services.chrony.enable);
  };
}
