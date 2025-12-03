{
  pkgs,
  lib,
  self,
  ...
}:
let
  DATASET = "osiris/safe";

  snapUnitName = "zfs-snapshot-osiris";
  pruneUnitName = "zfs-snapshot-prune-osiris";
in
{
  systemd =
    let
      description = "Create snapshot of ${DATASET}";
      documentation = [ "man:zfs-snapshot(8)" ];
    in
    {
      timers."${snapUnitName}" = {
        inherit description documentation;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          # OnStartupSec = "30m";
          # OnUnitInactiveSec = "60m";
          # RandomizedDelaySec = "10m";
          OnCalendar = "hourly";
          RandomizedDelaySec = "10m";
          Persistent = true; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.
        };
      };

      services."${snapUnitName}" = {
        inherit description documentation;
        unitConfig = rec {
          Requires = [
            "zfs.target"
          ];
          After = Requires;
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeScript "${snapUnitName}-script" ''
            #!/${pkgs.dash}/bin/dash

            set -eu

            PATH="${
              lib.makeBinPath [
                pkgs.coreutils # date
              ]
            }"
            ZFS_CMD='/run/booted-system/sw/bin/zfs'
            # NOTE: No `+` character in snapshot name
            time_="$(date -- '+%Y-%m-%dT%H:%M:%S%Z')"
            snapshot_name="${DATASET}@autosnap_''${time_}"

            echo "Creating snapshot ''${snapshot_name}" >/dev/null
            "$ZFS_CMD" snapshot -r -- "$snapshot_name"
          '';
        };
      };

      timers."${pruneUnitName}" = {
        inherit description documentation;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:00:00";
          RandomizedDelaySec = "60m";
          Persistent = true;
        };
      };

      services."${pruneUnitName}" = {
        inherit description documentation;
        unitConfig = rec {
          Requires = [
            "zfs.target"
          ];
          After = Requires;
        };
        path = [
          # allow to use zfs from the booted system
          "/run/booted-system/sw"
        ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.escapeShellArgs [
            "${self.packages.${pkgs.stdenv.hostPlatform.system}.zfs-snapshot-prune}/bin/zfs-snapshot-prune"
            "--keep-last"
            "3"
            "--keep-within-hourly"
            "PT24H"
            "--keep-within-daily"
            "P7D"
            "--keep-within-weekly"
            "P3W"
            "--offset"
            "240" # 4 hours
            "--filter"
            "^(autosnap|rustic)_.*"
            "--recursive"
            "--"
            DATASET
          ];
        };
      };
    };

}
