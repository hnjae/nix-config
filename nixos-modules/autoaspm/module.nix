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

        # Security hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateNetwork = true; # No network needed

        # Need access to PCI devices
        PrivateDevices = false;

        # Restrict capabilities
        NoNewPrivileges = true;
        ProtectKernelTunables = false; # Need to write to /sys/bus/pci
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;

        # Restrict system calls
        SystemCallFilter = "@system-service";
        SystemCallArchitectures = "native";

        # Additional restrictions
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = "none"; # No network sockets

        # Memory protections
        MemoryDenyWriteExecute = true;
      };
    };
  };
}
