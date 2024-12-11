{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.isDesktop {
    home.packages = builtins.concatLists [
      (lib.lists.optional pkgs.stdenv.isLinux pkgs.alacritty)
      (lib.lists.optional pkgs.stdenv.isDarwin pkgsUnstable.alacritty)
    ];
    default-app.fromApps = ["Alacritty"];

    xdg.configFile."alacritty/alacritty.toml" = {
      text = lib.concatLines [
        (builtins.readFile ./resources/alacritty.toml)
        (lib.strings.optionalString (genericHomeCfg.base24.enable)
          (lib.concatLines [
            (builtins.readFile (config.scheme {
              templateRepo = ./resources/base24-alacritty;
              target = "default-256";
            }))
            (let
              COLORFGBG =
                if (genericHomeCfg.base24.darkMode)
                then "15;0"
                else "0;15";
            in ''
              [env]
              COLORFGBG="${COLORFGBG}"
              TERM = "xterm-256color" # To use 256 color on tmux
            '')
          ]))
      ];
    };
  };
}
