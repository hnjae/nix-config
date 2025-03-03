# WIP
/*
  README:
    - `/secrets/rclone.conf` 에 적절한 rclone 설정을 넣어두어야 한다.
    - `rclone.conf` 의 access_token 이 업데이트 될수 있어야 하므로, sops 로 모듈에 번들하지 않는다.

  # TODO: networkmanager 에서 metered connection 인지 물어보기. <2025-03-03>
*/
{
  config,
  pkgs,
  lib,
  ...
}:
let
  envResticOnedrive = pkgs.writeText "env-restic-onedrive" (
    lib.generators.toKeyValue { } {
      RESTIC_COMPRESSION = "auto";
      RESTIC_PACK_SIZE = 128;
      GOGC = "off";
      GOMEMLIMIT = 4 * 1024 * 1024 * 1024; # 4GiB
      RCLONE_BWLIMIT = "4M"; # MiB/s
    }
  );

  offSiteBackupName = "off-site";
in
{
  sops.secrets."restic-onedrive" = {
    sopsFile = ./secrets/restic-onedrive;
    format = "binary";
  };

  # Overrides
  systemd.services."restic-backups-${offSiteBackupName}" = {
    serviceConfig = {
      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecCondition = [
        "${pkgs.inetutils}/bin/ping -c 1 'https://onedrive.live.com"
      ];
      # ExecCondition = pkgs.writeScript "${offSiteBackupName}-condition" ''
      #   #!${pkgs.dash}/bin/dash
      #
      #   PATH="${pkgs.inetutils}/bin"
      #
      #   ping -c 1.1.1.1
      # '';
    };
    unitConfig = {
      ConditionACPower = true;
    };
  };

  services.restic.backups = {
    "${offSiteBackupName}" = {
      # user = "hnjae";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      repository = "rclone:onedrive:.restic";
      rcloneConfigFile = "/secrets/rclone.conf";
      paths = [
        "/home/hnjae/Projects"
        # "/home/hnjae/Pictures"
        # "/home/hnjae/Documents"
        # "/home/hnjae/Library"
      ];
      environmentFile = "${envResticOnedrive}";
      passwordFile = config.sops.secrets."restic-onedrive".path;
      initialize = false;
      inhibitsSleep = false;
      extraBackupArgs = [
        "--one-file-system"
      ];
      exclude = [
        # Linux
        ".directory" # KDE
        ".thumbnails" # KDE (maybe)
        ".Trash-*"
        ".nfs*"
        ".fuse_hidden*"

        # macOS
        ".DS_Store"
        "._*" # thumbnails

        # MS Windows
        "Thumbs.db"
        "Desktop.ini"
        "desktop.ini"
        "$RECYCLE.BIN"

        # Misc
        ".localized"
        ".cache"

        # temporary files
        "*.parts"
        ".direnv" # nix-flake

        # vscode
        ".vscode-server"

        # vim
        "tags"
        "*.swp"
        "*~"

        # shell related
        "fish_variables"
        "*.zcompdump"
        ".zsh_history"

        # python related
        ".venv"
        "__pycache__"
        ".pyc"

        # python tools
        ".ropeproject"
        ".mypy_cache"
        ".ruff_cache"
        ".pyre"
        "dist"

        # nodejs related
        "node_modules"
        "dist"
      ];
    };
  };
}
