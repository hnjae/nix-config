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

  # Helper to build command-line arguments
  mkArgs =
    backupName: backupCfg:
    let
      # Build list of command-line arguments
      args =
        lib.optionals (backupCfg.paths != null) [
          "--paths"
          (lib.concatStringsSep "," backupCfg.paths)
        ]
        ++ lib.optionals (backupCfg.tags != [ ]) (
          lib.concatMap (tag: [
            "--tag"
            tag
          ]) backupCfg.tags
        )
        ++ lib.optional (backupCfg.label != null) "--label ${lib.escapeShellArg backupCfg.label}"
        ++ lib.optional (
          backupCfg.description != null
        ) "--description ${lib.escapeShellArg backupCfg.description}"
        ++ lib.optional (backupCfg.groupBy != null) "--group-by ${lib.escapeShellArg backupCfg.groupBy}"
        ++ lib.optional (backupCfg.parent != null) "--parent ${lib.escapeShellArg backupCfg.parent}"
        ++ lib.optional backupCfg.skipIfUnchanged "--skip-if-unchanged"
        ++ lib.optional backupCfg.force "--force"
        ++ lib.optional backupCfg.ignoreCtime "--ignore-ctime"
        ++ lib.optional backupCfg.ignoreInode "--ignore-inode"
        ++ lib.optionals (backupCfg.globs != [ ]) (
          lib.concatMap (glob: [
            "--glob"
            (lib.escapeShellArg glob)
          ]) backupCfg.globs
        )
        ++ lib.optionals (backupCfg.iglobs != [ ]) (
          lib.concatMap (iglob: [
            "--iglob"
            (lib.escapeShellArg iglob)
          ]) backupCfg.iglobs
        )
        ++ lib.optional (backupCfg.globFile != null) "--glob-file ${lib.escapeShellArg backupCfg.globFile}"
        ++ lib.optional (
          backupCfg.iglobFile != null
        ) "--iglob-file ${lib.escapeShellArg backupCfg.iglobFile}"
        ++ lib.optional backupCfg.gitIgnore "--git-ignore"
        ++ lib.optional backupCfg.noRequireGit "--no-require-git"
        ++ lib.optional (
          backupCfg.customIgnorefile != null
        ) "--custom-ignorefile ${lib.escapeShellArg backupCfg.customIgnorefile}"
        ++ lib.optionals (backupCfg.excludeIfPresent != [ ]) (
          lib.concatMap (file: [
            "--exclude-if-present"
            (lib.escapeShellArg file)
          ]) backupCfg.excludeIfPresent
        )
        ++ lib.optional (
          backupCfg.excludeLargerThan != null
        ) "--exclude-larger-than ${lib.escapeShellArg backupCfg.excludeLargerThan}"
        ++ lib.optional (backupCfg.time != null) "--time ${lib.escapeShellArg backupCfg.time}"
        ++ lib.optional backupCfg.deleteNever "--delete-never"
        ++ lib.optional (
          backupCfg.deleteAfter != null
        ) "--delete-after ${lib.escapeShellArg backupCfg.deleteAfter}"
        ++ lib.optional (backupCfg.host != null) "--host ${lib.escapeShellArg backupCfg.host}"
        ++ lib.optional backupCfg.dryRun "--dry-run";
    in
    lib.concatStringsSep " " args;

  # Create systemd service for each backup
  mkService =
    backupName: backupCfg:
    let
      escapedName = lib.replaceStrings [ "/" ] [ "-" ] backupName;
      cmdArgs = mkArgs backupName backupCfg;
    in
    {
      description = "Rustic Btrfs Backup: ${backupName}";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = "restic";
        Group = "restic";

        # Environment
        EnvironmentFile = backupCfg.environmentFile;

        # Capabilities (run as non-root)
        AmbientCapabilities = [
          "CAP_SYS_ADMIN"
          "CAP_DAC_READ_SEARCH"
        ];

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [ "/run/lock" ];

        # Network (required for remote repositories)
        PrivateNetwork = false;

        # Execute backup (using shell for proper argument escaping)
        ExecStart = ''/bin/sh -c "${package}/bin/rustic-btrfs ${cmdArgs} ${lib.escapeShellArg backupCfg.subvolume}"'';
      };
    };

  # Create systemd timer for each backup
  mkTimer =
    backupName: backupCfg:
    let
      escapedName = lib.replaceStrings [ "/" ] [ "-" ] backupName;
    in
    {
      description = "Timer for Rustic Btrfs Backup: ${backupName}";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = backupCfg.timerConfig.OnCalendar;
        RandomizedDelaySec = backupCfg.timerConfig.RandomizedDelaySec;
        Persistent = backupCfg.timerConfig.Persistent;
      };
    };
in
{
  options.my.services.${projectName} = {
    backups = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            subvolume = lib.mkOption {
              type = lib.types.str;
              description = "Path to Btrfs subvolume to backup";
            };

            environmentFile = lib.mkOption {
              type = lib.types.str;
              description = "Path to environment file containing RUSTIC_REPOSITORY, RUSTIC_PASSWORD_*, etc.";
            };

            timerConfig = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  OnCalendar = lib.mkOption {
                    type = lib.types.str;
                    default = "daily";
                    description = "systemd OnCalendar specification";
                  };

                  RandomizedDelaySec = lib.mkOption {
                    type = lib.types.str;
                    default = "1h";
                    description = "Randomized delay before running backup";
                  };

                  Persistent = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Run missed backups on boot";
                  };
                };
              };
              default = { };
              description = "systemd timer configuration";
            };

            # Backup options
            paths = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
              description = "Specific paths within subvolume for partial backup (relative paths)";
            };

            tags = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Tags for snapshot";
            };

            label = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Label for snapshot";
            };

            description = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Snapshot description (overrides auto-generated)";
            };

            # Parent processing
            groupBy = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = "host,paths";
              description = "Group snapshots by criterion";
            };

            parent = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Specific parent snapshot";
            };

            skipIfUnchanged = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Skip backup if unchanged vs parent";
            };

            force = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "No parent, read all files";
            };

            ignoreCtime = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Ignore ctime changes";
            };

            ignoreInode = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Ignore inode changes";
            };

            # Exclude options
            globs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Glob patterns to exclude/include";
            };

            iglobs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Case-insensitive glob patterns";
            };

            globFile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Read glob patterns from file";
            };

            iglobFile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Read case-insensitive glob patterns from file";
            };

            gitIgnore = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Use .gitignore rules";
            };

            noRequireGit = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Don't require git repo for git-ignore";
            };

            customIgnorefile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Treat file as .gitignore";
            };

            excludeIfPresent = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Exclude directories containing these files";
            };

            excludeLargerThan = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Exclude files larger than size";
            };

            # Snapshot metadata
            time = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Override backup time (ISO 8601)";
            };

            deleteNever = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Mark snapshot as uneraseable";
            };

            deleteAfter = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Auto-delete snapshot after duration";
            };

            host = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Override hostname";
            };

            dryRun = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Pass --dry-run to rustic (no actual backup)";
            };
          };
        }
      );
      default = { };
      description = "Backup configurations";
    };
  };

  config = lib.mkIf (cfg.backups != { }) {
    # Create restic user and group
    users.users.restic = {
      isSystemUser = true;
      group = "restic";
      description = "Rustic backup service user";
    };

    users.groups.restic = { };

    # Create lock directory via tmpfiles.d
    systemd.tmpfiles.rules = [ "d /run/lock/rustic-btrfs 0755 restic restic - -" ];

    # Create systemd services and timers for each backup
    systemd.services = lib.mapAttrs' (
      name: cfg:
      let
        escapedName = lib.replaceStrings [ "/" ] [ "-" ] name;
        serviceName = "rustic-btrfs-${escapedName}";
      in
      lib.nameValuePair serviceName (mkService name cfg)
    ) cfg.backups;

    systemd.timers = lib.mapAttrs' (
      name: cfg:
      let
        escapedName = lib.replaceStrings [ "/" ] [ "-" ] name;
        timerName = "rustic-btrfs-${escapedName}";
      in
      lib.nameValuePair timerName (mkTimer name cfg)
    ) cfg.backups;
  };
}
