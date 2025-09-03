{ pkgs, lib, ... }:
{
  programs.starship = {
    enable = true;
    interactiveOnly = true;
    settings = {
      add_newline = true;
      follow_symlinks = false;
      format = builtins.concatStringsSep "" [
        "$username"
        "$hostname"
        "$shlvl"
        "$directory"
        "$nix_shell"
        "$direnv"
        "$container"
        "$cmd_duration"
        "$line_break"
        "$shell"
        "$character"
      ];

      shell = {
        disabled = false;
      };

      username = {
        show_always = true;
        format = "[$user]($style)";
        style_user = "bold purple";
      };

      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style) in ";
        style = "bold purple";
      };

      directory = {
        read_only = " 󰍁";
        read_only_style = "bold red";
        style = "bold blue";
      };

      direnv = {
        allowed_msg = " direnv";
        denied_msg = "";
        detect_files = [ ];
        disabled = false;
        format = "[([via](fg) $allowed)]($style) ";
        loaded_msg = "";
        not_allowed_msg = "";
        style = "bold green";
        unloaded_msg = "";
      };

      nix_shell = {
        format = "via [$symbol$state]($style) ";
        heuristic = false;
        impure_msg = "impure";
        pure_msg = "pure";
        style = "bold blue";
        symbol = "󱄅 ";
        unknown_msg = "unknown";
      };

      container = {
        format = "via [$symbol \\[$name\\]]($style) ";
        style = "bold red";
        symbol = "⬢ ";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    ############################################################################
    # Things will be written to `/etc/zshrc` (Order represents order in zshrc) #
    ############################################################################
    # setOptions = [ ];
    histSize = 100;
    # histFile = ''"''${XDG_DATA_HOME:-$HOME/.local/data}/.zsh_history"'';
    enableGlobalCompInit = false;
    enableBashCompletion = true;

    vteIntegration = true;
    autosuggestions = {
      enable = true;
      strategy = [
        "match_prev_cmd"
        "completion"
      ];
    };
    syntaxHighlighting = {
      enable = true;
    };
    interactiveShellInit = ''
      FZF_DEFAULT_OPTS="--color=16,border:8 --layout=reverse --height=22 --marker=░"
      ZVM_CURSOR_STYLE_ENABLED=false

      source '${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh'
      source '${pkgs.fzf}/share/fzf/key-bindings.zsh'

      autoload -U compinit && compinit
      source '${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh'
    '';

    enableLsColors = true;
    # promptInit = "";

    ##############################################
    # Things will be written to `/etc/zprofile` ##
    ##############################################
    # loginShellInit = '''';
  };

  programs.bash = {
    blesh.enable = false;
  };

  environment.systemPackages = [
    pkgs.bashInteractive
    pkgs.dash
    pkgs.fzf

    # pkgs.fish
    # (lib.hiPrio (
    #   pkgs.makeDesktopItem {
    #     name = "fish";
    #     desktopName = "This should not be displayed.";
    #     exec = ":";
    #     noDisplay = true;
    #   }
    # ))
  ];
}
