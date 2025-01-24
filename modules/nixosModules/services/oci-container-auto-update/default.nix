# NOTE: Currently, only Podman is supported. <2024-08-04>
# TODO: podman-pod 으로 묶어 실행하는 경우 대응 (컨테이너간 의존 관계가 있으니, 전부 pull 하고 한번에 시작 해결) <2025-01-02>
# TODO: 각 container 별로 onCalendar 설정 가능하게 하기 <2025-01-02>
# TODO: virtualisation.oci-containers.containers.<name>.serviceName 을 활용. NixOS 24.11 에서 생겼나? <2025-01-06>
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.oci-container-auto-update;
  cfgOciContainers = config.virtualisation.oci-containers.containers;
  inherit (config.virtualisation.oci-containers) backend;

  inherit (lib) mkEnableOption mkOption types;
in
{
  options.services.oci-container-auto-update = {
    enable = mkEnableOption "";

    onCalendar = mkOption {
      type = types.str;
      description = ''
        In the format of a systemd timer onCalendar configuration.
        See {manpage}`systemd.time(7)`.
      '';
      default = "Mon *-*-* 04:00:00";
    };
    randomizedDelaySec = mkOption {
      default = "15min";
      type = types.str;
      description = ''
        This value must be a time span in the format specified by
        {manpage}`systemd.time(7)`
      '';
    };
    persistent = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Persistent option in the [Timer] section of the unit. See systemd.timer(5) and systemd.time(7) for details.
      '';
    };

    containers = mkOption {
      default = { };
      example = ''
        {
          traefik.enable = true;
        }
      '';
      type = types.attrsOf (
        types.submodule (_: {
          options = {
            enable = mkEnableOption "";
          };
        })
      );
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = builtins.concatLists [
      (
        let
          checkSingleContainer = containerName: opts: {
            assertion =
              !(opts.enable)
              || (
                builtins.hasAttr containerName cfgOciContainers
                && cfgOciContainers.${containerName}.imageFile == null
              );
            message = "${containerName} is not valid";
          };
        in
        (lib.mapAttrsToList checkSingleContainer cfg.containers)
      )
      (
        let
          checkSingleContainer = containerName: opts: {
            assertion =
              !(opts.enable)
              || (builtins.hasAttr "${backend}-${containerName}" config.systemd.services);
            message = "Systemd units ${backend}-${containerName}.service does not exists";
          };
        in
        (lib.mapAttrsToList checkSingleContainer cfg.containers)
      )
      [
        {
          assertion = backend == "podman";
          message = "virtualisation.oci-containers.backend is not podman";
        }
      ]
    ];

    systemd =
      let
        genSingleUnit =
          containerName: opts:
          let
            name = "${backend}-${containerName}-update";
            targetService = "${backend}-${containerName}.service";
            package = import ./package {
              inherit
                pkgs
                name
                targetService
                containerName
                ;
              inherit (cfgOciContainers."${containerName}") image;
            };
            description = "Update ${containerName}";
          in
          lib.attrsets.optionalAttrs opts.enable {
            services."${name}" = {
              inherit description;

              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${package}/bin/${name}";
              };
            };
            timers."${name}" = {
              inherit description;

              wantedBy = [ "timers.target" ];

              timerConfig = {
                OnCalendar = cfg.onCalendar;
                RandomizedDelaySec = cfg.randomizedDelaySec;
                Persistent = cfg.persistent;
              };
            };
          };
      in
      lib.mkMerge (lib.mapAttrsToList genSingleUnit cfg.containers);
  };
}
