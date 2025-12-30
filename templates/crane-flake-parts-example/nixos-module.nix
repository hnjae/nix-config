{ localFlake, projectName, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.${projectName};

  inherit (pkgs.stdenv) hostPlatform;
  package = localFlake.packages.${hostPlatform.system}.${projectName};
in
{
  options.my.services.${projectName} = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
      }
    ];

    environment.systemPackages = [
      package
    ];

    systemd =
      let
        documentation = [
        ];
        description = "";
      in

      {
        services.${projectName} = {
          inherit documentation description;
          after = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";

            ExecStart = lib.escapeShellArgs [ ];
            RemainAfterExit = true;

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

        timers.${projectName} = {
          inherit documentation description;

          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "yearly";
            RandomizedDelaySec = "5m";
          };

        };
      };
  };
}
