{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [gitui];

    xdg.configFile."gitui/theme.ron" = lib.mkIf genericHomeCfg.base24.enable {
      source = config.scheme {templateRepo = ./base24-gitui;};
    };
  };
}
