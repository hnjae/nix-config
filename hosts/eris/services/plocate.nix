{ pkgs, ... }:
{
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "never";
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

      "/zlocal"
      "/zsafe"
    ];
    pruneNames = [
      # VCS directories
      ".bzr"
      ".git"
      ".hg"
      ".svn"

      # Snapshots
      ".snapshots"
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
