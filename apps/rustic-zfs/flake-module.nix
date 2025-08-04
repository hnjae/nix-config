{
  perSystem =
    { pkgs, config, ... }:
    {
      packages = {
        rustic-zfs = import ./. { inherit pkgs; };
      };
      apps = {
        rustic-zfs = {
          type = "app";
          program = config.packages.rustic-zfs;
        };
      };
    };
}
