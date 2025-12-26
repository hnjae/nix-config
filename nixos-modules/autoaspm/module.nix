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
      type = lib.types.nullOr (lib.types.enum [
        "l0s"
        "l1"
        "l0sl1"
      ]);
      default = null;
      description = ''
        Default ASPM mode to set for all devices.
        If null, only devices specified in deviceModes will be patched.
      '';
    };
    deviceModes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.enum [
        "l0s"
        "l1"
        "l0sl1"
        "disabled"
      ]);
      default = { };
      example = {
        "8086:15b8" = "l0sl1";
        "10de:1234" = "disabled";
      };
      description = ''
        Device-specific ASPM mode overrides using vendor:device ID.
        These settings override the default mode and allow downgrade/disable.
      '';
    };
    skipDevices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "8086:9999" ];
      description = ''
        List of vendor:device IDs to skip (never patch).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.mode != null || cfg.deviceModes != { };
        message = "autoaspm: either mode or deviceModes must be specified";
      }
    ];

    environment.systemPackages = [
      package
    ];

    systemd.services.${project} =
      let
        baseArgs = [
          "${lib.getExe package}"
          "--run"
        ] ++ lib.optionals (cfg.mode != null) [
          "--mode"
          "${cfg.mode}"
        ];

        deviceModeArgs = lib.flatten (
          lib.mapAttrsToList
            (vendorDevice: mode: [
              "--device-mode"
              "${vendorDevice}=${mode}"
            ])
            cfg.deviceModes
        );

        skipArgs = lib.flatten (
          map (vendorDevice: [
            "--skip"
            vendorDevice
          ]) cfg.skipDevices
        );

        allArgs = baseArgs ++ deviceModeArgs ++ skipArgs;
      in
      {
        description = "Automatically activate ASPM on all supported devices";
        wants = [ "systemd-udev-settle.service" ];
        after = [ "systemd-udev-settle.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          Nice = 5;

          ExecStart = lib.escapeShellArgs allArgs;

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
