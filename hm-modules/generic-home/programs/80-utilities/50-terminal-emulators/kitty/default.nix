{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (builtins) readFile;
in {
  programs.kitty = {
    enable = genericHomeCfg.isDesktop;
    package = pkgsUnstable.kitty;

    # https://sw.kovidgoyal.net/kitty/shell-integration/#shell-integration
    # shellIntegration.mode = "no-rc";

    shellIntegration.mode = "no-cursor";
    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.optionalString (genericHomeCfg.base24.enable) (readFile
        (config.scheme {
          templateRepo = ./base24-kitty;
          target = "default";
        })))

      (readFile ./share/fonts.conf)
      (readFile ./share/cursor.conf)
      (readFile ./share/tab-bar/tab-bar.conf)
      (readFile ./share/window-layout.conf)
      (readFile ./share/map.conf)

      ''
        font_size ${toString genericHomeCfg.terminalFontSize}
      ''
    ];
  };

  xdg.configFile."kitty/tab_bar.py".source = ./share/tab-bar/tab_bar.py;

  home.sessionVariables."GLFW_IM_MODULE" = lib.mkIf pkgs.stdenv.isLinux "ibus";
}
