{
  perSystem =
    { pkgs, config, ... }:
    {
      packages = {
        wincompat-rename = import ./. { inherit pkgs; };
      };
      apps = {
        wincompat-rename = {
          type = "app";
          program = config.packages.wincompat-rename;
        };
      };
    };
}
