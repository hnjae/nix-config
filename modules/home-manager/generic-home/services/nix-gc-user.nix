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
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage -d";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      PrivateNetwork = "yes";
    };
  };
  systemd.user.timers."${serviceName}" = optionalAttrs isLinux {
    Unit = {inherit Description;};

    Timer = {
      # OnCalendar = builtins.concatStringsSep "," ["Tue" "Fri"];
      OnCalendar = [
        "Tue *-*-* 04:00:00"
        "Fri *-*-* 04:00:00"
      ];

      RandomizedDelaySec = "24h";
      Persistent = true;
    };

    Install = {WantedBy = ["timers.target"];};
  };
}
