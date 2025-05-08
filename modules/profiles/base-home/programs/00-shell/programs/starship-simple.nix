{ config, lib, ... }:
let
  starshipCmd = "${config.home.profileDirectory}/bin/starship";
in
{
  programs.zsh.initExtra = ''
    if [[ "$TERM" != "dumb" ]] && hash starship >/dev/null 2>&1 && [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
      eval "$(${starshipCmd} init zsh)"
    fi
  '';

  programs.starship = {
    # "$schema" = 'https://starship.rs/config-schema.json'
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = true;
    enableZshIntegration = false;

    settings = {
      format = lib.concatStrings [
        # Basic
        "$username"
        "$hostname"
        "$directory"

        # VCS
        "$fossil_branch"
        "$fossil_metrics"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$hg_branch"

        # venv
        "$python"
        "$nix_shell"
        "$direnv"
        "$container"

        # MISC
        "$cmd_duration"

        # LINE BREAK
        "$line_break"

        # prompt
        "$character"
      ];
      add_newline = true;
      follow_symlinks = false;

      #######################
      # Basic
      #######################

      username = {
        disabled = false;
        style_user = "bold yellow";
        format = ''[$user](bold yellow)'';
      };
      hostname = {
        ssh_only = true;
        ssh_symbol = "󰀂 "; # nf-md
        format = ''([@$hostname( $ssh_symbol)](bold yellow) in )'';
      };
      directory = {
        style = "bold blue";
        read_only = " 󰍁"; # nf-md
        read_only_style = "bold red";
        truncation_length = 6;
      };
      character = {
        # ❯
        success_symbol = "[%](bold purple)";
        error_symbol = "[%](bold red)";
        vicmd_symbol = "[❮](green)";
        vimcmd_replace_one_symbol = "[❮](purple)";
        vimcmd_replace_symbol = "[❮](purple)";
        vimcmd_visual_symbol = "[❮](yellow)";
      };
      cmd_duration = {
        # 'took [$duration]($style) '
        min_time_to_notify = 30 * 1000; # milliseconds
        show_notifications = false;
      };

      #######################
      # VCS
      #######################

      git_branch = {
        # symbol = " "; # nf-oct-git_branch
        symbol = "󰘬 "; # nf-md-git-branch
      };
      git_commit = {
        # tag_symbol = ""; # nf-oct-tag
        tag_symbol = "󰓼"; # nf-md
      };

      git_status = {
        style = "cyan";
        format = "(($conflicted)($renamed$staged)($modified$untracked)($deleted) )($ahead_behind$stashed )";

        up_to_date = "[✔](bold green)";
        ahead = "[↑\${count}](yellow)";
        behind = "[↓\${count}](yellow)";
        diverged = "[↓\${behind_count}↑\${ahead_count}](yellow)";

        stashed = "[⚑\${count}](yellow)";

        conflicted = "[=\${count}](red)";
        modified = "[!\${count}](blue)";
        untracked = "[?\${count}](blue)";
        deleted = "[×\${count}](cyan)"; # stage 에 올려도 계속 뜸

        staged = "[+\${count}](yellow)";
        renamed = "[»\${count}](yellow)"; # nf-oct-file-moved
      };

      ####################################
      # VENV
      ####################################
      nix_shell = {
        # Style
        # format = ''[$symbol( \($state\))]($style) '';
        format = ''via [$symbol$state]($style) '';
        style = "bold light-blue";
        symbol = "󱄅 "; # nf-md-nix

        # Configs
        heuristic = false; # ghostty 와 충돌 <2025-02-07>
        impure_msg = "impure";
        unknown_msg = "unknown";
        pure_msg = "pure";
      };

      container = {
        format = ''via [$symbol \[$name\]]($style) '';
        style = "bold red";
        symbol = "⬢ ";
      };

      direnv = {
        format = ''[([via](fg) $allowed)]($style) '';
        style = "bold green";
        disabled = false;

        allowed_msg = " direnv";
        not_allowed_msg = "";
        denied_msg = "";
        loaded_msg = "";
        unloaded_msg = "";

        # disable detection using files
        detect_files = [ ];
      };

      python = {
        # format = ''[([via](fg) 󰌠 $virtualenv)]($style) '';
        format = ''[[via](fg) 󰌠 venv]($style) '';
        style = "bold yellow";
        disabled = false;

        # disable detection using files
        detect_extensions = [ ];
        detect_files = [ ];
        detect_folders = [ ];
      };
    };
  };
}
