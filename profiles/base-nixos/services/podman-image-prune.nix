{
  config,
  lib,
  pkgs,
  ...
}:
let
  serviceName = "podman-image-prune";
  documentation = [
    "man:podman-image-prune(1)"
  ];
  description = "Run `podman image prune` on a schedule to remove unused images";
in
{
  config = lib.mkIf config.virtualisation.podman.enable {
    systemd.services.${serviceName} = {
      inherit documentation;
      inherit description;

      path = lib.lists.optional config.boot.zfs.enabled config.boot.zfs.package;

      unitConfig = {
        Requires = [ "multi-user.target" ];
        After = [ "multi-user.target" ];
      };

      serviceConfig = {
        Type = "oneshot";

        # systemd.exec
        Nice = 19;
        IOSchedulingPriority = 7;

        ExecStart = lib.escapeShellArgs [
          "${pkgs.podman}/bin/podman"
          "image"
          "prune"
          "--all"
          "--force"
        ];
      };
    };

    systemd.timers.${serviceName} = {
      inherit documentation;
      inherit description;

      unitConfig = {
        After = [ "multi-user.target" ];
      };

      timerConfig = {
        OnCalendar = [
          "Monday *-*-* 04:00:00"
        ];
        RandomizedDelaySec = "2h";
        Persistent = true;
      };

      wantedBy = [ "timers.target" ];
    };
  };
}
