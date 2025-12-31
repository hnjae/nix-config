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
      # NixOS 25.11 Default:
      ".bzr"
      ".cache"
      ".git"
      ".hg"
      ".svn"

      ".snapshots"
      ".zfs"

      ".ansible"
      ".deploy-gc"
      ".direnv"
      ".venv"
      "node_modules"

      "__pycache__"
      "mypy_cache"
      "pytet_cache"
      "ruff_cache"
    ];
  };

  # Override locate.nix module
  systemd.services.update-locatedb.serviceConfig.Type = "oneshot";
}
