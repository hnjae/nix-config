{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
  base24 = config.scheme {templateRepo = ./base24-shell;};
in {
  # NOTE: Following terminal emulators do not support to set a colors in within the 256 colorspace <2024-03-11>
  # konsole, qterminal, lxterminal, rxvt-unicode

  config = lib.mkIf genericHomeCfg.base24.enable {
    programs.zsh.initExtra = ''
      if [ -z "$SSH_TTY" ] &&
        [ -z "$NVIM" ] &&
        { [ -z "$ZELLIJ" ] || [ "$TERM" = "xterm-256color" ]; } &&
        [ "$TERM" != "tmux-256color" ] &&
        [ "$TERM" != "screen.xterm-256color" ] &&
        {
          { [ "$ZELLIJ" != "" ] && [ "$TERM" = "xterm-256color" ]; } ||
            [ "$TERM" = "wezterm" ] ||
            [ "$TERM" = "foot" ] ||
            [ "$TERM" = "alacritty" ] ||
            [ "$TERM" = "contour" ] ||
            [ "$TERM" = "xterm-termite" ] ||
            [ "$TERM" = "xterm-kitty" ] ||
            [ "$TERM" = "xterm" ] ||
            [ "$TERM" = "linux" ]
        }; then

        if [ "$TERM" != "linux" ]; then
          export BAT_THEME="base16-256"
        fi

        . "${base24}"
      fi
    '';

    programs.fish.interactiveShellInit = ''
      if not set -q SSH_TTY
        and not set -q NVIM
        and test "$TERM" != "tmux-256color"
        and test "$TERM" != "screen.xterm-256color"
        and test -z "$ZELLIJ" -o "$TERM" = "xterm-256color"
        and test \
          -n "$ZELLIJ" -o \
          "$TERM" = wezterm -o \
          "$TERM" = foot -o \
          "$TERM" = alacritty -o \
          "$TERM" = contour -o \
          "$TERM" = xterm-termite -o \
          "$TERM" = xterm-kitty -o \
          "$TERM" = xterm -o \
          "$TERM" = "linux"

        if test "$TERM" != "linux"
          set -x BAT_THEME "base16-256"
        end

        eval sh '"'(realpath ${base24})'"'
      end
    '';
  };
}
