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
    programs.zsh.initContent = ''
      if [[ "$TERM" != "dumb" ]] && [[ "$ALACRITTY_WINDOW_ID" != "" ]] && [[ "$TERM_PROGRAM" == "" ]]; then
        function _set_terminal_title() {
            echo -e "\033]0;$*\007"
        }

        _alacritty_precmd() {
          _set_terminal_title "''${PWD##*/}"
        }
        precmd_functions+=(_alacritty_precmd)

        _alacritty_preexec() {
          _set_terminal_title "''${1} (''${PWD##*/})"
        }
        preexec_functions+=(_alacritty_preexec)
      fi
    '';

    home.packages = builtins.concatLists [
      (lib.lists.optional pkgs.stdenv.isLinux pkgs.alacritty)
      (lib.lists.optional pkgs.stdenv.isDarwin pkgsUnstable.alacritty)
    ];

    default-app.fromApps = [ "Alacritty" ];

    xdg.configFile."alacritty/base16.toml" = lib.mkIf (baseHomeCfg.base24.enable) {
      text = (
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
  };
}
