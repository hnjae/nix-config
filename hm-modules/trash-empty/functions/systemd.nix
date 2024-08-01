{
  trash-cli,
  mountPoint,
  emptyDays,
  onCalendar,
}: let
  # TODO: mountPath name change (/ to -)
  serviceName = "trash-empty-${mountPoint}";
  Unit = {
    Description = "Empty trash of '${mountPoint}'";
    Documentation = ["man:trash-empty(1)"];
  };
in {
  systemd.user.services."${serviceName}" = {
    inherit Unit;
    Service = {
      Type = "oneshot";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      Nice = 19;
      # TODO: .Trash-1000 식의 접두어 붙이기 <2024-07-10>
      ExecStart = "${trash-cli}/bin/trash-empty -f --trash-dir '${mountPoint}' ${
        toString emptyDays
      }";
    };
  };
  systemd.user.timers.${serviceName} = {
    inherit Unit;
    Timer = {
      OnCalendar = onCalendar;
      RandomizedDelaySec = "10m";
      Persistent = true;
    };

    Install = {WantedBy = ["timers.target"];};
  };
}
