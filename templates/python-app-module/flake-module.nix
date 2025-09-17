{
  perSystem =
    { pkgs, config, ... }:
    {
      packages = {
        zfs-prune = import ./. { inherit pkgs; };
      };
      apps = {
        zfs-prune = {
          type = "app";
          program = config.packages.zfs-prune;
        };
      };
    };
}
