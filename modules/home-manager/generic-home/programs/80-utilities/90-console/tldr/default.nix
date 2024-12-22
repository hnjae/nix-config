{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}: let
  # genericHomeCfg = config.generic-home;
  inherit (pkgs.stdenv) isLinux;

  package = pkgsUnstable.tealdeer;

  serviceName = "tldr-update";
  Description = "daily update tldr";

  # Documentation = [""]; no man page for tealdeer <NixOS 23.11; tealdeer 1.6.1>

  tldrUpdateScript = pkgs.writeShellScript "tldr-update" ''
    set -eu

    MAX_RETRY=5
    PAUSE_SEC=120
    i=0
    while [ "$i" -lt "$MAX_RETRY" ]; do
      if ${pkgs.inetutils}/bin/ping -c 1 1.1.1.1 >/dev/null 2>&1; then
        break
      fi

      if [ "$i" -ge "$MAX_RETRY" ]; then
        echo "ERROR: Internet is not connected. Aborting execution."
        exit 1
      fi

      echo "INFO: Waiting Internet connection. Will retry after ''${PAUSE_SEC}s."
      sleep "$PAUSE_SEC"
    done
    unset i

    ${package}/bin/tldr --update
  '';
in {
  home.packages = [package];

  systemd.user.services."${serviceName}" = lib.mkIf isLinux {
    Unit = {
      inherit Description;

      # NOTE: systemd-user 에서는 network-online 을 알수 없음
      After = [
        # "dbus.socket"
        # "pipewire.socket"
        # "xdg-desktop-portal.service"
        "multi-user.target"
      ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${tldrUpdateScript}";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      # Nice = 19;
    };
  };

  systemd.user.timers."${serviceName}" = lib.mkIf isLinux {
    Unit = {inherit Description;};

    Timer = {
      OnCalendar = "*-*-* 04:00:00";
      AccuracySec = "1h";
      Persistent = true;
    };

    Install = {WantedBy = ["timers.target"];};
  };
}
