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
{
  config,
  pkgs,
  lib,
  ...
}:
let
  description = "GC nix system profiles and boot-entries";
  documentation = [ "man:nix-env-delete-generations(1)" ];
  serviceName = "nix-gc-system-generations";
  cfg = config.services.${serviceName};
  package = pkgs.callPackage ./package { };

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  # do not run this if something wrong with system
  # requires = ["boot-complete.target"];
  # man:systemd.special(7)
  # NOTE: <NixOS 24.05>: Unit boot-complete.target not found.

  # NOTE: boot-complete.target 이 NixOS 24.05 기준 작동되지 않아, 중요한 다른 타겟을
  # 추가하는 것으로 대체.
  requires = [
    "network-online.target"
    "time-sync.target"
    "machines.target" # containers
    "cryptsetup.target"
    "local-fs.target"
    "remote-fs.target"
    "multi-user.target"
    "getty.target"
  ] ++ (lib.lists.optional config.services.xserver.enable "graphical.target");
in
{
  options.services.${serviceName} = {
    enable = mkEnableOption (lib.mDoc "");

    delThreshold = mkOption {
      type = types.int;
      default = 14;
      description = lib.mdDoc "The last x days to keep";
    };

    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 04:00:00";
      description = "How often to clean old generations";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.${serviceName} = {
      inherit documentation;
      inherit description;
      inherit requires;
      inherit (cfg) enable;

      serviceConfig = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        # Nice = 19;
        ExecStart = "${package}/bin/nix-gc-system-generations --run ${toString (cfg.delThreshold)}";
      };
    };

    systemd.timers.${serviceName} = {
      inherit documentation;
      inherit description;
      inherit requires;
      inherit (cfg) enable;

      timerConfig = {
        OnCalendar = cfg.onCalendar;
        AccuracySec = "1h";
        Persistent = true;
      };

      wantedBy = [ "timers.target" ];
    };
  };
}
