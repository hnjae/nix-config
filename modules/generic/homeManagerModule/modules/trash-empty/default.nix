# WIP
{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.trash;
in {
  options.trash = {
    enable = lib.mkEnableOption (lib.mdDoc "trash");

    mountPoints = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    emptyDays = mkOption {
      type = types.int;
      default = 1;
    };

    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 04:00:00";
      description = "See systemd.time(7)";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.empty-trash = {
      Unit = {
        Description = "Empty trash";
        Documentation = ["man:trash-empty(1)"];
      };
      Service = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        Nice = 19;
        ExecStart = "${pkgs.trash-cli}/bin/trash-empty -f 1";
        # TODO: requiremountpoints if mountpoint <2024-07-08>
      };
    };
    systemd.user.timers.empty-trash = {
      Unit = {};
      Timer = {
        OnCalendar = cfg.onCalendar;
        RandomizedDelaySec = "12m";
        Persistent = true;
      };

      Install = {WantedBy = ["timers.target"];};
    };
  };
}
