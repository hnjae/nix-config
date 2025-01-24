{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf baseHomeCfg.isDesktop {
    home.packages = builtins.concatLists [
      (lib.lists.optional pkgs.stdenv.isLinux pkgs.alacritty)
      (lib.lists.optional pkgs.stdenv.isDarwin pkgsUnstable.alacritty)
    ];
    default-app.fromApps = ["Alacritty"];

    # xdg.configFile."alacritty/alacritty.toml" = {
    #   text = lib.concatLines [
    #     (builtins.readFile ./resources/alacritty.toml)
    #     (lib.strings.optionalString (baseHomeCfg.base24.enable)
    #       (lib.concatLines [
    #         (builtins.readFile (config.scheme {
    #           templateRepo = ./resources/base24-alacritty;
    #           target = "default-256";
    #         }))
    #         (let
    #           COLORFGBG =
    #             if (baseHomeCfg.base24.darkMode)
    #             then "15;0"
    #             else "0;15";
    #         in ''
    #           [env]
    #           COLORFGBG="${COLORFGBG}"
    #           TERM = "xterm-256color" # To use 256 color on tmux
    #         '')
    #       ]))
    #   ];
    # };

    xdg.configFile."alacritty/base16.toml".text =
      lib.strings.optionalString (baseHomeCfg.base24.enable)
      (lib.concatLines [
        (builtins.readFile (config.scheme {
          templateRepo = ./resources/base24-alacritty;
          target = "default-256";
        }))
        (let
          COLORFGBG =
            if (baseHomeCfg.base24.darkMode)
            then "15;0"
            else "0;15";
        in ''
          [env]
          COLORFGBG="${COLORFGBG}"
          TERM = "xterm-256color" # To use 256 color on tmux
        '')
      ]);
  };
}
