{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    programs.foot = {
      enable = pkgs.stdenv.isLinux;
      package = pkgsUnstable.foot;
      server.enable = true;
    };

    default-app.fromApps = ["org.wezfurlong.wezterm"];

    xdg.configFile."foot/foot.ini" =
      lib.attrsets.optionalAttrs
      (pkgs.stdenv.isLinux && config.programs.foot.enable) {
        text = builtins.concatStringsSep "\n" [
          ''
            # term=foot-extra
            # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
            # man 5 foot.ini
          ''

          ''
            bold-text-in-bright=no
            font=Monospace:size=${toString genericHomeCfg.terminalFontSize}
          ''

          (lib.strings.optionalString (genericHomeCfg.base24.enable)
            (lib.concatLines [
              (builtins.readFile
                (config.scheme {templateRepo = ./resources/base24-foot;}))
              (let
                COLORFGBG =
                  if (config.generic-home.base24.darkMode)
                  then "15;0"
                  else "0;15";
              in ''
                [environment]
                COLORFGBG="${COLORFGBG}"
              '')
            ]))
        ];
      };

    xdg.desktopEntries."org.codeberg.dnkl.foot-server" = {
      type = "Application";
      name = "foot-server";
      comment = "this should not be displayed";
      exec = ":";
      noDisplay = true;
    };

    xdg.desktopEntries."org.codeberg.dnkl.foot" = lib.mkIf (config.programs.foot.server.enable) {
      type = "Application";
      name = "foot";
      comment = "this should not be displayed";
      exec = ":";
      noDisplay = true;
    };

    xdg.desktopEntries."org.codeberg.dnkl.footclient" = lib.mkIf (!config.programs.foot.server.enable) {
      type = "Application";
      name = "foot";
      comment = "this should not be displayed";
      exec = ":";
      noDisplay = true;
    };
  };
}
