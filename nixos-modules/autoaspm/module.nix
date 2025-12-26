{ localFlake, project, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.${project};

  inherit (pkgs.stdenv) hostPlatform;
  package = localFlake.packages.${hostPlatform.system}.${project};
in
{
  options.my.services.${project} = {
    enable = lib.mkEnableOption "Automatically activate ASPM on all supported devices";
    mode = lib.mkOption {
      type = lib.types.enum [
        "l0s"
        "l1"
        "l0sl1"
      ];
      description = "ASPM mode to set";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      package
    ];

    systemd.services.${project} = {
      description = "Automatically activate ASPM on all supported devices";
      wants = [ "systemd-udev-settle.service" ];
      after = [ "systemd-udev-settle.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        Nice = 5;

        ExecStart = lib.escapeShellArgs [
          "${lib.getExe package}"
          "--run"
          "--mode"
          "${cfg.mode}"
        ];

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = false; # Require access to /dev
        PrivateIPC = true;
        PrivateMounts = true;
        PrivateNetwork = true; # No network needed
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = false; # Need to write to /sys/bus/pci
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = "none"; # No network sockets
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
