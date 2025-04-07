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
    # home.packages = with pkgsUnstable; [ gitui ];
    programs.gitui = {
      enable = true;
      package = pkgsUnstable.gitui;
      # theme = lib.mkIf baseHomeCfg.base24.enable (config.scheme { templateRepo = ./base24-gitui; });
    };

    # TODO: configure this in home-manager module <2025-04-07>
    xdg.configFile."gitui/theme.ron" = lib.mkIf baseHomeCfg.base24.enable (
      lib.mkForce {
        source = config.scheme { templateRepo = ./base24-gitui; };
      }
    );
  };
}
