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
        (builtins.readFile ./alacritty.toml)
        (lib.strings.optionalString (genericHomeCfg.base24.enable)
          (lib.concatLines [
            (builtins.readFile (config.scheme {
              templateRepo = ./base24-alacritty;
              target = "default-256";
            }))
            (let
              COLORFGBG =
                if (config.base24.variant == "light")
                then "0;15"
                else "15;0";
            in ''
              [env]
              COLORFGBG="${COLORFGBG}"
            '')
          ]))
        ''
          [font]
          size = ${toString genericHomeCfg.terminalFontSize}
        ''
      ];
    };
  };
}
