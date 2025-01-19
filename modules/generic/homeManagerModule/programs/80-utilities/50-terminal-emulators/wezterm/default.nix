{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  # package = pkgsUnstable.wezterm;
  package = pkgs.wezterm;
  shellIntgrationStr = ''
    . "${package}/etc/profile.d/wezterm.sh"
  '';
  genericHomeCfg = config.generic-home;

  appId = "org.wezfurlong.wezterm";
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
    # home.packages = [package];

    default-app.fromApps = [appId];
    services.flatpak.packages = [appId];
    services.flatpak.overrides."${appId}" = {
      # https://github.com/wez/wezterm/issues/4962
      Context = {sockets = ["!wayland"];};
    };
    home.shellAliases = {
      wezterm = "flatpak --user run org.wezfurlong.wezterm";
    };
    # home.packages = [
    #   (pkgs.writeScriptBin "wezterm" ''
    #     #!${pkgs.dash}/bin/dash
    #     flatpak --user run org.wezfurlong.wezterm "$@"
    #   '')
    # ];
    programs.zsh.initExtra = builtins.readFile ./resources/wezterm-zsh-chpwd.zsh;

    # programs.bash.initExtra = shellIntgrationStr;
    # programs.zsh.initExtra = shellIntgrationStr;

    # xdg.dataFile."wezterm/colors/base24.toml".source =
    #   config.scheme
    #   {templateRepo = ./base24-wezterm;};

    # xdg.configFile = lib.mergeAttrsList (builtins.concatLists [
    #   (map
    #     (x: {"wezterm/${x}" = {source = ./resources/xdg.configFile/wezterm/${x};};}) [
    #       "colors/codedark.toml"
    #       "colorscheme.lua"
    #       "fonts.lua"
    #       "gpu.lua"
    #       "mouse-bindings.lua"
    #       "ui.lua"
    #       "utils.lua"
    #       "wezterm.lua"
    #     ])
    #
    #   [
    #     {
    #       "wezterm/hm-declared.lua".text = let
    #         COLORFGBG =
    #           if (config.generic-home.base24.darkMode)
    #           then "15;0"
    #           else "0;15";
    #       in (lib.concatLines [
    #         ''
    #           local M = {}
    #
    #           M.apply = function(opts, wezterm)
    #         ''
    #         ''
    #           opts.color_scheme = "base24"
    #         ''
    #         ''
    #           opts.set_environment_variables = {
    #             COLORFGBG = "${COLORFGBG}",
    #           }
    #         ''
    #         # ''
    #         #   opts.font_size = ${toString genericHomeCfg.terminalFontSize}
    #         # ''
    #         (builtins.readFile
    #           (config.scheme {templateRepo = ./resources/base24-wezterm-ui;}))
    #         ''
    #           end
    #
    #           return M
    #         ''
    #       ]);
    #     }
    #     {
    #       "wezterm/colors/base24.toml".source =
    #         config.scheme {templateRepo = ./resources/base24-wezterm;};
    #     }
    #   ]
    # ]);
  };
}
