/*
NOTE:
#### nix-collect-garbage -d vs nix-store --gc
<https://discourse.nixos.org/t/what-is-the-difference-if-any-between-nix-collect-garbage-and-nix-store-gc/45078/2>

`nix.gc` (`nix-collect-garbage`) 는 old profiles 도 추가로 지우는 차이가 있다.

#### from man:nix-collect-garbage(1)

> •  --delete-old / -d
>    Delete all old generations of profiles.
>
>    This  is  the equivalent of invoking nix-env --delete-generations old
>    on each found profile.
*/
{
  config,
  lib,
  ...
}: let
  serviceName = "nix-store-gc";
  documentation = ["man:nix-store-gc(1)"];
  description = "run nix-store --gc";
  binPath = "/run/current-system/sw/bin/nix-store";
  cfg = config.services.${serviceName};

  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.services.${serviceName} = {
    enable = mkEnableOption (lib.mDoc "");

    onCalendar = mkOption {
      type = types.str;
      default = "Tue,Fri *-*-* 04:00:00";
      description = '''';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.${serviceName} = {
      inherit documentation;
      inherit description;

      serviceConfig = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        Nice = 19;
        ExecStart = "${binPath} --gc";
      };
    };

    systemd.timers.${serviceName} = {
      inherit documentation;
      inherit description;

      timerConfig = {
        OnCalendar = cfg.onCalendar;
        RandomizedDelaySec = "90m";
        Persistent = true;
      };

      wantedBy = ["timers.target"];
    };
  };
}
