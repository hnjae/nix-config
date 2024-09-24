{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      # A modern load testing tool, using Go and JavaScript
      k6

      # httpie # sends http requests
    ];

    services.flatpak.packages =
      lib.mkIf (genericHomeCfg.isDesktop && genericHomeCfg.installTestApps)
      [
        "com.usebruno.Bruno" # Proprietary # https://github.com/usebruno/bruno mit
        "io.httpie.Httpie" # Proprietary
        # "rest.insomnia.Insomnia" # mit
        # "com.getpostman.Postman" # Proprietary
      ];
  };
}
