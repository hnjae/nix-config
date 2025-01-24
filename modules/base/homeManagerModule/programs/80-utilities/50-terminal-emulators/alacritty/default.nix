{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDesktop {
    home.packages = builtins.concatLists [
      (lib.lists.optional pkgs.stdenv.isLinux pkgs.alacritty)
      (lib.lists.optional pkgs.stdenv.isDarwin pkgsUnstable.alacritty)
    ];
    default-app.fromApps = [ "Alacritty" ];

    xdg.configFile."alacritty/base16.toml".text =
      lib.strings.optionalString (baseHomeCfg.base24.enable)
        (
          lib.concatLines [
            (builtins.readFile (
              config.scheme {
                templateRepo = ./resources/base24-alacritty;
                target = "default-256";
              }
            ))
            (
              let
                COLORFGBG = if (config.base-home.base24.variant == "light") then "0;15" else "15;0";
              in
              ''
                [env]
                COLORFGBG="${COLORFGBG}"
                TERM = "xterm-256color" # To use 256 color on tmux
              ''
            )
          ]
        );
  };
}
