# NOTE: arguments passed from the flake directly
{
  self,
  ...
}:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.autoaspm;
in
{
  options.services.autoaspm = {
    enable = lib.mkEnableOption "Automatically activate ASPM on all supported devices";
    package = lib.mkPackageOption self.packages.${pkgs.stdenv.hostPlatform.system} "autoaspm" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    systemd.services.autoaspm = {
      description = "Automatically activate ASPM on all supported devices";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.escapeShellArg [
          "${lib.getExe cfg.package}"
          "--run"
          "--mode"
          "l0sl1"
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
