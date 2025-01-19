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
    home.packages = [pkgsUnstable.termite];

    xdg.configFile."termite/config" = {
      text = builtins.concatStringsSep "\n" [
        ''
          [options]
          cursor_blink = off
          cursor_shape = block
          font = Monospace ${toString genericHomeCfg.terminalFontSize}
          scrollbar = off
          allow_bold = true
          bold_is_bright = false
          dynamic_title = true
          clickable_url = true
          hyperlinks = true
          search_wrap = true
          smart_copy = false

          gtk_dark_theme = ${
            if genericHomeCfg.base24.darkMode
            then "true"
            else "false"
          }

          icon_name = utilities-terminal
        ''
        (lib.strings.optionalString (genericHomeCfg.base24.enable)
          (builtins.readFile
            (config.scheme {templateRepo = ./resources/base24-termite;})))
      ];
    };
  };
}
