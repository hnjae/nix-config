/*
  README:
    다음의 역할을 수행합니다.
      * 오래된 nixos-generations 을 제거.
      * 같은 날 생성된 여러개의 nixos-generations 중 하나만 제외하고 제거.
      * 부팅 때 사용된 generation 이 있다면 제거 대상에서 스킵.

    이유:
      NixOS를 가지고 작업하다보면 여러개의 generations 이 생깁니다. 개인적인
      경험으로 작업 도중 생긴 generations 은 보통 필요가 없습니다. 그날 생성된
      generations 중 가장 최신의 것만 남겨서, 혼란을 최소화합니다.

      부팅 때 사용했던 generation 과 current generation 은 절대 제거하지 않아,
      부팅 가능한 NixOS generation 을 남겨둡니다.
*/
{ localFlake, project, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  description = "GC nix system profiles and boot-entries";
  documentation = [ "man:nix-env-delete-generations(1)" ];

  cfg = config.my.services.${project};

  inherit (pkgs.stdenv) hostPlatform;
  package = localFlake.packages.${hostPlatform.system}.${project};

  # do not run this if something wrong with system
  # requires = ["boot-complete.target"];
  # man:systemd.special(7)
  # NOTE: <NixOS 24.05>: Unit boot-complete.target not found.

  # NOTE: boot-complete.target 이 NixOS 24.05 기준 작동되지 않아, 중요한 다른 타겟을
  # 추가하는 것으로 대체.
  Requires = lib.flatten [
    "network-online.target"
    "time-sync.target"
    "machines.target" # containers
    "cryptsetup.target"
    "local-fs.target"
    "remote-fs.target"
    "multi-user.target"
    "getty.target"
    (lib.lists.optional config.services.xserver.enable "graphical.target")
  ];
in
{
  options.my.services.${project} = {
    enable = lib.mkEnableOption (lib.mDoc "automatic NixOS generation garbage collection");

    keepDays = lib.mkOption {
      type = lib.types.int;
      default = 14;
      description = "The last x days to keep.";
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 04:00:00";
      description = "How often to clean old generations.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      package
    ];

    systemd.services.${project} = {
      inherit documentation;
      inherit description;

      unitConfig = {
        inherit Requires;
        After = Requires;
      };

      serviceConfig = {
        Type = "oneshot";

        # systemd.exec
        Nice = 19;
        IOSchedulingPriority = 7;

        ExecStart = lib.escapeShellArgs [
          "${lib.getExe package}"
          "--run"
          "--delete-older-than-days"
          (toString cfg.keepDays)
        ];
      };
    };

    systemd.timers.${project} = {
      inherit documentation;
      inherit description;

      timerConfig = {
        OnCalendar = cfg.onCalendar;
        RandomizedDelaySec = "30m";
        Persistent = true;
      };

      wantedBy = [ "timers.target" ];
    };
  };
}
