{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.attrsets) optionalAttrs;
  inherit (pkgs.stdenv) isLinux;
  serviceName = "nix-gc-user";
  Description = "Run nix-collect-garbarge";
in {
  systemd.user.services."${serviceName}" = lib.mkIf isLinux {
    Unit = {inherit Description;};

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 3d";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      PrivateNetwork = "yes";
    };
  };
  systemd.user.timers."${serviceName}" = optionalAttrs isLinux {
    Unit = {inherit Description;};

    Timer = {
      OnCalendar = [
        "Tue *-*-* 04:00:00"
        "Fri *-*-* 04:00:00"
        # "Thu *-*-* 04:00:00"
        # "Sat *-*-* 04:00:00"
      ];

      RandomizedDelaySec = "50m";
      Persistent = true;
    };

    Install = {WantedBy = ["timers.target"];};
  };
}
