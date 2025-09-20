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

      serviceConfig = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
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

      timerConfig = {
        OnCalendar = "Monday *-*-* 04:00:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };

      wantedBy = [ "timers.target" ];
    };
  };
}
