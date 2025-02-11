{ pkgs, lib, ... }:
{
  programs.tmux = {
    enable = true;

    clock24 = true;
    mouse = true;
    escapeTime = 0;
    prefix = "M-n";
    terminal = "tmux-256color";

    plugins = [
      {
        # prefix + space
        # NOTE: no wayland support <2025-02-11>
        # plugin = pkgs.tmuxPlugins.tmux-thumbs;
      }
    ];

    extraConfig = lib.concatLines [
      ''
        set-option -g status-keys vi
        set-option -g mode-keys vi
      ''
      ''
        # switch panes using Alt-arrow without prefix
        bind -n M-Left select-pane -L
        bind -n M-Down select-pane -D
        bind -n M-Up select-pane -U
        bind -n M-Right select-pane -R
        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R
      ''
      ''
        # for neovim's autoread
        set-option -g focus-events on

        # true color support (`termguicolors` of neovim)
        set-option -a terminal-features 'xterm-256color:RGB'
      ''
      ''
        # Style
        set -g status-right '#H '
      ''
      ''
        # https://yazi-rs.github.io/docs/image-preview#tmux
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM
      ''
    ];
  };
}
