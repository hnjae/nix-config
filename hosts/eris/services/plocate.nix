{ pkgs, lib, ... }:
{
  systemd.tmpfiles.rules = [
    "z /zlocal/cache/locatedb 0640 root plocate"
    "L /var/cache/locatedb - - - - /zlocal/cache/locatedb"
  ];

  environment.defaultPackages = [
    (lib.hiPrio (
      pkgs.writeScriptBin "updatedb" ''
        #!${pkgs.dash}/bin/dash

        nohup sudo systemctl start update-locatedb.service >/dev/null 2>&1 &
        exec journalctl --follow --since "4s ago" --output=short-full --unit update-locatedb.service
      ''
    ))
  ];

  # HELP: man:updatedb.conf(5)
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "never";
    output = "/zlocal/cache/locatedb";
    prunePaths = [
      # NixOS 25.11 Default:
      "/tmp"
      "/var/tmp"
      "/var/cache"
      "/var/lock"
      "/var/run"
      "/var/spool"
      "/nix/store"
      "/nix/var/log/nix"

      # 내가 추가한 경로:
      "/boot"
      "/boot_fallback_a"
      "/boot_fallback_b"
      "/mnt" # Temporary mounts
      "/srv"
      "/var"
      "/zlocal/@"
      "/zsafe/@"
    ];
    pruneNames = [
      /*
        NOTE:
          - Pattern mechanism is not used
          - Only directory names ase skipped
      */

      # VCS directories
      ".bzr"
      ".git"
      ".hg"
      ".svn"

      # Snapshots
      ".snapshot"
      ".snapshots" # snapper
      ".zfs"

      # Disposable directories
      ".ansible"
      ".cache"
      ".claude"
      ".deploy-gc"
      ".direnv"
      ".venv"
      "node_modules"

      # Cache directories
      ".mypy_cache"
      ".pytest_cache"
      ".pytet_cache"
      ".ruff_cache"
      "__pycache__"
    ];
  };

  # Override locate.nix module
  systemd.services.update-locatedb.serviceConfig.Type = "oneshot";
}
