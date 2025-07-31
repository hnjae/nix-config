{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  serviceName = "trash-empty";
  Description = "trash-empty";
in
{
  systemd.user.services."${serviceName}" = lib.mkIf isLinux {
    Unit = { inherit Description; };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.trash-cli}/bin/trash-empty 1";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      Nice = 19;
      PrivateNetwork = "yes";
    };
  };
  systemd.user.timers."${serviceName}" = optionalAttrs isLinux {
    Unit = { inherit Description; };

    Timer = {
      OnCalendar = "*-*-* 04:00:00";
      RandomizedDelaySec = "45m";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
