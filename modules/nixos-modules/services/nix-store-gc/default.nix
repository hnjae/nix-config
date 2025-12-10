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
}:
let
  serviceName = "nix-store-gc";
  documentation = [
    "https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-store-gc"
    # "nix store gc --help"
  ];
  description = "run nix store gc";
  cfg = config.my.services.${serviceName};

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.my.services.${serviceName} = {
    enable = mkEnableOption (lib.mDoc "");
  };

  config = mkIf cfg.enable {
    systemd.services.${serviceName} = {
      inherit documentation;
      inherit description;

      unitConfig = {
        Requires = [ "multi-user.target" ];
        After = [ "multi-user.target" ];
      };

      serviceConfig = {
        Type = "oneshot";

        # systemd.exec
        Nice = 19;
        IOSchedulingPriority = 7;

        ExecStart = lib.escapeShellArgs [
          "${config.nix.package.out}/bin/nix"
          "store"
          "gc"
          "--verbose"
        ];
      };
    };

    systemd.timers.${serviceName} = {
      inherit documentation;
      inherit description;

      timerConfig = {
        OnCalendar = [
          "Monday *-*-* 04:00:00"
        ];
        RandomizedDelaySec = "2h";
        Persistent = true;
      };

      unitConfig = {
        After = [ "multi-user.target" ];
      };

      wantedBy = [ "timers.target" ];
    };
  };
}
