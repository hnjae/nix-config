# NOTE: use nf-seti-* <2024-02-15>
# NOTE: check style before adding new one. (Must use color from terminal) <2024-02-15>
# NOTE: dimmed -> normal <2024-02-15>
# NOTE: some terminal uses bold font when printing bright-{color}
{ config, ... }:
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
      format = "$all";
      add_newline = true;
      follow_symlinks = false;
      directory = {
        read_only = " 󰍁"; # nf-md
        read_only_style = "bold red";
        truncation_length = 6;
      };
      character = {
        # ❯
        success_symbol = "[>](green)";
        error_symbol = "[>](red)";
        vicmd_symbol = "[<](green)";
        vimcmd_replace_one_symbol = "[<](purple)";
        vimcmd_replace_symbol = "[<](purple)";
        vimcmd_visual_symbol = "[<](yellow)";
      };
      cmd_duration = {
        min_time_to_notify = 30 * 1000; # milliseconds
        show_notifications = false;
      };
      username.disabled = false;
      hostname = {
        ssh_only = false;
        ssh_symbol = "󰀂 "; # nf-md
        style = "bold green";
      };
      shell = {
        disabled = false;
        fish_indicator = "󰈺"; # nf-md-fish
        zsh_indicator = "%";
        bash_indicator = "$"; # nf-cod-terminal_bash
        # nu_indicator = "nu";
      };
      time = {
        disabled = true;
        format = "[$time]($style) ";
        style = "white";
      };
      sudo = {
        symbol = "󰪌 "; # nf-md-account_supervisor_circle
        disabled = true;
      };
      battery.disabled = true;
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
        # NOTE: $all_status == $conflicted$stashed$deleted$renamed$modified$staged$untracked
        format = "(($conflicted)($renamed$staged)($modified$untracked)($deleted)($ahead_behind)($stashed) )";
        up_to_date = "[✔](bold green)";

        ahead = "[↑\${count}](yellow)";
        behind = "[↓\${count}](yellow)";
        diverged = "[⇕↓\${behind_count}↑\${ahead_count}](yellow)";

        stashed = "[⚑\${count}](yellow)";

        conflicted = "[=\${count}](red)";
        modified = "[!\${count}](blue)";
        untracked = "[?\${count}](blue)";
        deleted = "[×\${count}](cyan)"; # stage 에 올려도 계속 뜸

        staged = "[+\${count}](yellow)";
        renamed = "[»\${count}](yellow)"; # nf-oct-file-moved
      };
      nix_shell = {
        format = ''via [$symbol$name( \($state\))]($style) '';
        symbol = "󱄅 "; # nf-md-nix
        heuristic = false; # ghostty 와 충돌 <2025-02-07>

        # state
        # impure_msg = "";
        unknown_msg = "unknown";
        pure_msg = "pure";
      };
      container = {
        style = "bold red";
        # symbol = " "; # nf-oct-container
        symbol = "⬢' ";
      };
      docker_context.symbol = " "; # nf-seti-docker
      memory_usage = {
        symbol = "󰍛 "; # nf-md
        style = "bold white";
      };
      aws.symbol = "  "; # nf-dev-aws
      azure.symbol = " "; # nf-code-azure
      gcloud.symbol = " "; # nf-dev-google_cloud_platform
      openstack.symbol = "󰅣 "; # nf-md
      guix_shell.symbol = " "; # nf-linux-gnu_guix
      gradle.symbol = " "; # nf-seti-gradle
      package = {
        symbol = "󰏗 "; # nf-md
        style = "bold yellow";
      };
      c = {
        symbol = " "; # nf-custom-c
        style = "bold bright-green";
      };
      crystal.symbol = " "; # nf-seti-crystal
      dart.symbol = " "; # nf-seti-dart
      elixir.symbol = " "; # nf-seti-elixir
      elm.symbol = " "; # nf-seti-elm
      golang.symbol = " "; # nf-seti-go
      haskell.symbol = " "; # nf-seti-haskell
      java = {
        symbol = " "; # nf-dev-java
        style = "bold red";
      };
      julia.symbol = " "; # nf-seti-julia
      kotlin.symbol = "󱈙 "; # nf-md
      lua.symbol = " "; # nf-seti-lua
      nim.symbol = " "; # nf-seti-nim
      nodejs.symbol = "󰎙 "; # nf-md-nodjes
      ocaml.symbol = " "; # nf-seti-ocaml
      perl = {
        symbol = " "; # nf-seti-perl
        style = "bold bright-green";
      };
      purescript.symbol = " "; # nf-seti-purescript
      python.symbol = " "; # nf-seti-python
      rlang.symbol = " "; # nf-seti-r
      ruby.symbol = "󰴭 "; # nf-md
      rust.symbol = " "; # nf-seti-rust
      scala = {
        symbol = " "; # nf-seti-scala
        style = "red";
      };
      vlang.symbol = " "; # nf-custom-v_lang
      zig.symbol = " "; # nf-seti-zig
    };
  };
}
