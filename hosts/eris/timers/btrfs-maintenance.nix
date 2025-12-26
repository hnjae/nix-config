# TODO: add btrfs balance <2025-12-27>
let
  serviceName = "btrfs-maintenance";
  target = "/nix";
in
{
  config,
  pkgs,
  lib,
  ...
}:
{
  systemd =
    let
      description = "btrfs scrub on /nix";
      documentation = [ "man:btrfs-scrub(8)" ];
    in
    {
      services.${serviceName} = {
        inherit description documentation;
        # scrub prevents suspend2ram or proper shutdown
        conflicts = [
          "shutdown.target"
          "sleep.target"
        ];
        before = [
          "shutdown.target"
          "sleep.target"
        ];

        serviceConfig = {
          Type = "oneshot";

          # 커널 스케쥴링
          Nice = 19;
          IOSchedulingClass = "idle";

          ExecStart =
            let
              # https://btrfs.readthedocs.io/en/latest/btrfs-scrub.html
              isIOPrioClassIdleSupported = lib.elem config.hardware.block.defaultScheduler [
                "bfq"
                "kyber"
              ];
            in
            # NOTE: https://github.com/kdave/btrfsmaintenance
            [
              # 알아서 escape 해줌
              (pkgs.writeScript "btrfs-balance@${target}" ''
                #!${pkgs.dash}/bin/dash

                set -eu

                PATH="${lib.makeBinPath [ pkgs.btrfs-progs ]}"

                for BB in 0 5 10; do
                  echo "Starting data balance with usage threshold: ''${BB}%" >&2
                  btrfs balance start -dusage="$BB" -- "${target}"
                done

                for BB in 0 5; do
                  echo "Starting metadata balance with usage threshold: ''${BB}%" >&2
                  btrfs balance start -musage="$BB" -- "${target}"
                done
              '')
              (lib.escapeShellArgs (
                lib.flatten [
                  "${pkgs.btrfs-progs}/bin/btrfs"
                  "scrub"
                  "start"
                  "-B"
                  # TODO: test if limit is working <2025-12-27>
                  "--limit"
                  "100M"
                  (lib.lists.optionals isIOPrioClassIdleSupported [
                    "-c"
                    "3" # idle class
                  ])
                  (lib.lists.optionals (!isIOPrioClassIdleSupported) [
                    "-n"
                    "7"
                  ])
                  target
                ]
              ))
            ];
        };
      };

      timers.${serviceName} = {
        inherit description documentation;
        timerConfig = {
          OnCalendar = [
            # 26일 간격으로 수행 (년 14회)
            "*-01-01 02:55:00"
            "*-01-27 02:55:00"
            "*-02-22 02:55:00"
            "*-03-20 02:55:00" # 여기서 26.25 일 (2/22 → 3/20)
            "*-04-15 02:55:00"
            "*-05-11 02:55:00"
            "*-06-06 02:55:00"
            "*-07-02 02:55:00"
            "*-07-28 02:55:00"
            "*-08-23 02:55:00"
            "*-09-19 02:55:00" # 여기서 27일 (8/23 -> 9/19)
            "*-10-15 02:55:00"
            "*-11-10 02:55:00"
            "*-12-06 02:55:00"
          ];
          RandomizedDelaySec = "5m";
          Persistent = "true";
        };

        wantedBy = [ "timers.target" ];
        after = [ "multi-user.target" ];
      };
    };
}
