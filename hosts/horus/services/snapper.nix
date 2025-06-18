{ lib, ... }:
{
  # NOTE: root 소유의 .snapshots subvolume 이 있어야 함. <2023-10-03>
  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    persistentTimer = true;
  };

  systemd.timers.snapper-cleanup.timerConfig = lib.mkForce {
    # OnBootSec = lib.mkForce null;
    # OnUnitActiveSec = lib.mkForce null;
    OnCalendar = "*-*-* 04:02:00";
    Persistent = true;
  };
}
