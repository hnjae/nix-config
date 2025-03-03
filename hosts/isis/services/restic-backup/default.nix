# WIP
/*
  README:
    - `/secrets/rclone.conf` 에 적절한 rclone 설정을 넣어두어야 한다.
    - `rclone.conf` 의 access_token 이 업데이트 될수 있어야 하므로, sops 로 모듈에 번들하지 않는다.

  # TODO: check ac condition <2025-03-03>
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
      exclude = [
        # OS
        "Thumbs.db" # MS Windows
        ".DS_Store" # MacOS
        ".localized"
        ".directory" # KDE
        ".thumbnails"
        ".cache"

        # temporary files
        "*.parts"
        ".direnv" # nix-flake

        # editor
        ".vscode-server"

        # shell related
        "fish_variables"
        "*.zcompdump"
        ".zsh_history"

        # python related
        ".ropeproject"
        "__pycache__"
        ".mypy_cache"
        ".ruff_cache"
        ".pyc"
        ".venv"

        # nodejs related
        "node_modules"
        "npm-cache"
      ];
    };
  };
}
