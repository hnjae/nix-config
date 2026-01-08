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

  /*
    NOTE: NixOS 25.11, snapper 0.13.0

    기존 snapper 패키지의 snbk 에 btrfs 가 포함 안되어 있음.

    아래와 같은 에러 메시지 송출:

    Running transfer for backup config 'srv'.
    Thu 08 Jan 2026 22:50:16 <3> SystemCmd.cc(doWait):238 command "/usr/sbin/btrfs subvolume show -- /srv/.snapshots/1/snapshot" not found
    Thu 08 Jan 2026 22:50:16 <3> CmdBtrfs.cc(CmdBtrfsSubvolumeShow):167 command '/usr/sbin/btrfs subvolume show -- /srv/.snapshots/1/snapshot' failed: 127
    'btrfs subvolume show' failed
    Running transfer for backup config 'srv' failed.
    Running transfer for backup config 'zsafe'.
    Thu 08 Jan 2026 22:50:16 <3> SystemCmd.cc(doWait):238 command "/usr/sbin/btrfs subvolume show -- /zsafe/.snapshots/1/snapshot" not found
    Thu 08 Jan 2026 22:50:16 <3> CmdBtrfs.cc(CmdBtrfsSubvolumeShow):167 command '/usr/sbin/btrfs subvolume show -- /zsafe/.snapshots/1/snapshot' failed: 127
    'btrfs subvolume show' failed
    Running transfer for backup config 'zsafe' failed.
    Running transfer failed for 2 of 2 backup configs.
  */
  nixpkgs.overlays = [
    (_: prevPkgs: {
      snapper = prevPkgs.snapper.overrideAttrs (
        _: _: {
          configureFlags = [
            "--disable-ext4" # requires patched kernel & e2fsprogs
            "--disable-bachefs"
            "--disable-lvm"
            "--disable-zypp"

            "DIFF_BIN=${prevPkgs.diffutils}/bin/diff"
            "RM_BIN=${prevPkgs.coreutils}/bin/rm"

            # Make snbk to work
            "MKDIR_BIN=${prevPkgs.coreutils}/bin/mkdir"
            "RMDIR_BIN=${prevPkgs.coreutils}/bin/rmdir"
            "REALPATH_BIN=${prevPkgs.coreutils}/bin/realpath"
            "LS_BIN=${prevPkgs.coreutils}/bin/ls"
            "BTRFS_BIN=${prevPkgs.btrfs-progs}/bin/btrfs"
            "FINDMNT_BIN=${prevPkgs.util-linux}/bin/findmnt"
          ];

        }
      );
    })
  ];
}
