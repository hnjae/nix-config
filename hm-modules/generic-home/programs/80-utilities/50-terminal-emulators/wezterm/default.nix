# NOTE: wezterm의 설정은 nix 로 관리하지 않음.
{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  package = pkgsUnstable.wezterm;
  shellIntgrationStr = ''
    . "${package}/etc/profile.d/wezterm.sh"
  '';
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
    home.packages = [package];

    default-app.fromApps = ["org.wezfurlong.wezterm"];

    # programs.bash.initExtra = shellIntgrationStr;
    # programs.zsh.initExtra = shellIntgrationStr;

    # xdg.dataFile."wezterm/colors/base24.toml".source =
    #   config.scheme
    #   {templateRepo = ./base24-wezterm;};

    xdg.configFile = lib.mergeAttrsList (builtins.concatLists [
      (map
        (x: {"wezterm/${x}" = {source = ./xdg.configFile/wezterm/${x};};}) [
          "colors/codedark.toml"
          "colorscheme.lua"
          "fonts.lua"
          "gpu.lua"
          "mouse-bindings.lua"
          "ui.lua"
          "utils.lua"
          "wezterm.lua"
        ])

      [
        {
          "wezterm/hm-declared.lua".text = let
            COLORFGBG =
              if (config.base24.variant == "light")
              then "0;15"
              else "15;0";
          in (lib.concatLines [
            ''
              local M = {}

              M.apply = function(opts, wezterm)
            ''
            ''
              opts.color_scheme = "base24"
            ''
            ''
              opts.set_environment_variables = {
                COLORFGBG = "${COLORFGBG}",
              }
            ''
            # ''
            #   opts.font_size = ${toString genericHomeCfg.terminalFontSize}
            # ''
            (builtins.readFile
              (config.scheme {templateRepo = ./base24-wezterm-ui;}))
            ''
              end

              return M
            ''
          ]);
        }
        {
          "wezterm/colors/base24.toml".source =
            config.scheme {templateRepo = ./base24-wezterm;};
        }
      ]
    ]);
  };
}
