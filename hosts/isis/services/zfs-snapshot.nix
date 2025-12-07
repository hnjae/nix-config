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
          OnStartupSec = "20m";
          OnUnitInactiveSec = "90m";
          RandomizedDelaySec = "10m";
          Persistent = false; # OnStartupSec, OnUnitInactiveSec 조합에서는 작동 안한다.

          # OnCalendar = "hourly";
          # RandomizedDelaySec = "10m";
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

          # 커널 스케쥴링
          Nice = 10;
          IOSchedulingPriority = 7;

          ExecStart = pkgs.writeScript "${snapUnitName}-script" ''
            #!/${pkgs.dash}/bin/dash

            set -eu

            PATH="${
              lib.makeBinPath [
                pkgs.coreutils # date
              ]
            }"
            ZFS_CMD='/run/booted-system/sw/bin/zfs'

            time_="$(date -- '+%Y-%m-%d_%H:%M:%S_%Z')"
            snapshot_name="${DATASET}@autosnap_''${time_}"

            echo "INFO: Creating snapshot ''${snapshot_name}" >/dev/null
            exec "$ZFS_CMD" snapshot -r -- "$snapshot_name"
          '';
        };
      };

      timers."${pruneUnitName}" = {
        inherit description documentation;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:00:00";
          RandomizedDelaySec = "120m";
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

          # 커널 스케쥴링
          Nice = 10;
          IOSchedulingPriority = 7;

          ExecStart = lib.escapeShellArgs [
            "${self.packages.${pkgs.stdenv.hostPlatform.system}.zfs-snapshot-prune}/bin/zfs-snapshot-prune"
            "--keep-last"
            "1"
            "--keep-within-hourly"
            "PT8H"
            "--keep-within-daily"
            "P7D"
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
