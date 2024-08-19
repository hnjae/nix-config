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
          templateRepo = ./resources/base24-kitty;
          target = "default";
        })))

      (readFile ./resources/configs/fonts.conf)
      (readFile ./resources/configs/cursor.conf)
      (readFile ./resources/configs/tab-bar/tab-bar.conf)
      (readFile ./resources/configs/window-layout.conf)
      (readFile ./resources/configs/map.conf)

      ''
        font_size ${toString genericHomeCfg.terminalFontSize}
      ''
    ];
  };

  xdg.configFile."kitty/tab_bar.py".source = ./resources/configs/tab-bar/tab_bar.py;

  home.sessionVariables."GLFW_IM_MODULE" = lib.mkIf pkgs.stdenv.isLinux "ibus";
}
