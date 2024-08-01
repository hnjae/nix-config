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
    ];

    services.flatpak.packages =
      lib.mkIf (genericHomeCfg.isDesktop && genericHomeCfg.installTestApps)
      ["rest.insomnia.Insomnia"];
  };
}
