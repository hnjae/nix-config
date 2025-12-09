{ config, ... }:
let
  cfgZfs = config.boot.zfs;

  poolname = "isis";
  serviceName = "zfs-scrub";
in
{
  services.zfs.autoScrub.enable = false;

  systemd =
    let
      description = "Run zpool scrub";
      documentation = [ "man:zpool-scrub(8)" ];
      after = [
        # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/tasks/filesystems/zfs.nix
        # > Apparently scrubbing before boot is complete hangs the system? #53583
        "multi-user.target"
        "zfs.target"
      ];
    in
    {
      services."${serviceName}" = {
        inherit description documentation;
        after = after;
        requires = after;

        serviceConfig = {
          Type = "simple";

          # 커널 레벨에서 실행되기 때문에 아래 옵션들은 의미 없음. 2025-12-09
          # CPUSchedulingPolicy = "idle";
          # IOSchedulingClass = "idle";
          #
          # # systemd.resourced (cgroup)
          # IOWeight = "1"; # default 100
          #
          # IOReadBandwidthMax = [
          #   # NOTE: SI 단위임. <2025-12-09>
          #   # https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html
          #   "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4ce8e91d 600M"
          # ];

          ExecStart = "${cfgZfs.package}/bin/zpool scrub -w -- ${poolname}";
          ExecStop = "-${cfgZfs.package}/bin/zpool scrub -p -- ${poolname}";
        };
      };

      timers."${serviceName}" = {
        inherit description documentation;
        wantedBy = [ "timers.target" ];
        after = after;

        timerConfig = {
          OnCalendar = "monthly";
          RandomizedDelaySec = "12h";
          Persistent = true;
        };
      };
    };
}
