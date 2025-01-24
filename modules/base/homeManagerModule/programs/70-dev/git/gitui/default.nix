{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = with pkgsUnstable; [ gitui ];

    xdg.configFile."gitui/theme.ron" = lib.mkIf baseHomeCfg.base24.enable {
      source = config.scheme { templateRepo = ./base24-gitui; };
    };
  };
}
