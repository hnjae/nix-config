{
  pkgs,
  lib,
  self,
  ...
}:
let
  DATASET = "isis/safe";

  snapUnitName = "zfs-snapshot-isis";
  pruneUnitName = "zfs-snapshot-prune-isis";
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
          OnStartupSec = "30m";
          OnUnitInactiveSec = "60m"; # 5h
          RandomizedDelaySec = "12m";
          Persistent = false; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.
          # OnCalendar = "hourly";
        };
      };

      services."${snapUnitName}" = {
        inherit description documentation;
        unitConfig = rec {
          Requires = [
            "zfs.target"
          ];
          After = Requires;
          ConditionACPower = true;
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
            time_="$(date --utc '+%Y-%m-%dT%H:%M:%S.%3NZ')"
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
          ConditionACPower = true;
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.escapeShellArgs [
            "${self.packages.${pkgs.system}.zfs-snapshot-prune}/bin/zfs-snapshot-prune"
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
            "--dry-run"
            "--"
            DATASET
          ];
        };
      };
    };

}
