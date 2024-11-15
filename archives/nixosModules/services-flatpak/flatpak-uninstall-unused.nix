{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  description = "Uninstall unused flatpak packages";
  documentation = ["man:flatpak-uninstall(1)"];
  serviceName = "flatpak-uninstall-unused";
  # flatpakPath = "/run/current-system/sw/bin/flatpak";
  flatpakPath = "${pkgs.flatpak}/bin/flatpak";

  cfg = config.services.${serviceName};
in {
  options.services.${serviceName} = {
    enable = mkEnableOption (lib.mDoc "");

    onCalendar = mkOption {
      type = types.str;
      default = "daily";
      description = lib.mdDoc "";
    };
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;
    systemd.services."${serviceName}" = {
      inherit documentation;
      inherit description;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = builtins.concatStringsSep " " [
          flatpakPath
          "uninstall"
          "--unused"
          "--assumeyes"
          "--noninteractive"
        ];
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        Nice = 19;
      };
    };

    systemd.timers."${serviceName}" = {
      inherit documentation;
      inherit description;

      timerConfig = {
        OnCalendar = cfg.onCalendar;
        AccuracySec = "1d";
        Persistent = true;
      };

      wantedBy = ["timers.target"];
    };
  };
}
