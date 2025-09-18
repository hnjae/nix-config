{
  perSystem =
    { pkgs, config, ... }:
    {
      packages = {
        zfs-snapshot-prune = import ./. { inherit pkgs; };
      };
      apps = {
        zfs-snapshot-prune = {
          type = "app";
          program = config.packages.zfs-snapshot-prune;
        };
      };
    };
}
