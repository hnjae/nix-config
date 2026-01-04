/*
  Overrides following
    - services.snapper.cleanupInterval
    - services.snapper.snapshotInterval
    - services.snapper.persistentTimer
*/
{ lib, ... }:
{
  systemd.timers.snapper-timeline.timerConfig = lib.mkForce {
    OnBootSec = "1h";
    OnUnitActiveSec = "4h";
    RandomizedDelaySec = "5m";
    OnCalendar = [
      "*-*-* 03:55:00"
    ];
  };

  systemd.timers.snapper-cleanup.timerConfig = lib.mkForce {
    OnBootSec = "10m";
    OnCalendar = [
      "*-*-* 04:00:00"
      "*-*-* 16:00:00"
    ];
    RandomizedDelaySec = "5m";
  };
}
