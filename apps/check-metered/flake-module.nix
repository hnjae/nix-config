{
  perSystem =
    { pkgs, config, ... }:
    {
      packages = {
        check-metered = import ./. { inherit pkgs; };
      };
      apps = {
        check-metered = {
          type = "app";
          program = "${config.packages.check-metered}";
        };
      };
    };
}
