# NOTE: use nf-seti-* <2024-02-15>
# NOTE: check style before adding new one. (Must use color from terminal) <2024-02-15>
# NOTE: dimmed -> normal <2024-02-15>
# NOTE: some terminal uses bold font while printing bright-{color}
{...}: {
  programs.starship = {
    # "$schema" = 'https://starship.rs/config-schema.json'
    enable = true;
    # package = pkgsUnstable.starship;
    enableBashIntegration = false;

    settings = {
      format = "$all";
      add_newline = true;
      follow_symlinks = false;

      directory = {
        read_only = " "; # nf-oct-lock
        read_only_style = "bold red";
        truncation_length = 6;
      };
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)"; # nf-seti-error
        vicmd_symbol = "[❮](green)";
        vimcmd_replace_one_symbol = "[❮](purple)";
        vimcmd_replace_symbol = "[❮](purple)";
        vimcmd_visual_symbol = "[❮](yellow)";
      };
      # status = {
      #   enable = true;
      #   symbol = "";
      #   # not_executable_symbol
      #   # not_found_symbol
      #   # sigint_symbol
      #   # signal_symbol
      # };
      cmd_duration = {
        show_notifications = false;
        min_time_to_notify = 30 * 1000;
      };
      username.disabled = false;
      hostname = {
        ssh_only = false;
        ssh_symbol = "󰖟 ";
        style = "bold green";
      };
      shell = {
        disabled = false;
        fish_indicator = "󰈺"; # nf-md-fish
        zsh_indicator = "%";
        bash_indicator = ""; # nf-cod-terminal_bash
        unknown_indicator = "?";
      };
      time = {
        disabled = true;
        format = "[$time]($style) ";
        style = "white";
      };
      sudo = {
        symbol = "󰪌 "; # nf-md-account_supervisor_circle
        disabled = false;
      };
      git_branch = {
        symbol = " "; # nf-oct-git_branch
      };
      git_commit = {
        tag_symbol = ""; # nf-oct-tag
      };
      git_status = {
        style = "cyan";
        # format = "[$renamed$staged][$conflicted][$modified$deleted$untracked][$ahead_behind$stashed] ";
        format = "(($conflicted)($renamed$staged)($modified$untracked)($deleted)($ahead_behind)($stashed) )";
        # NOTE: $all_status == $conflicted$stashed$deleted$renamed$modified$staged$untracked
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
        symbol = "󱄅 "; # nf-md-nix
        heuristic = true;
      };
      container = {
        style = "bold red";
        symbol = " "; # nf-oct-container
      };
      docker_context.symbol = " "; # nf-seti-docker
      memory_usage = {
        symbol = "󰍛 ";
        style = "bold white";
      };

      aws.symbol = "  "; # nf-dev-aws
      azure.symbol = " "; # nf-code-azure
      gcloud.symbol = " "; # nf-dev-google_cloud_platform
      openstack.symbol = " "; # nf-oct-cloud

      # terraform = {
      #   symbol = " "; # nf-seti-terraform
      #   style = "";
      # };

      guix_shell.symbol = " "; # nf-linux-gnu_guix

      gradle.symbol = " "; # nf-seti-gradle
      # meson.symbol = ""

      package = {
        symbol = " "; # nf-oct-package
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
      # haxe.symbol = " "; # nf-seti-haxel
      java = {
        symbol = " "; # nf-dev-java
        style = "bold red";
      };
      julia.symbol = " "; # nf-seti-julia
      kotlin.symbol = " "; # nf-seti-kotlin
      lua.symbol = " "; # nf-seti-lua
      nim.symbol = " "; # nf-seti-nim
      nodejs.symbol = "󰎙 "; # nf-md-nodjes
      ocaml.symbol = " "; # nf-seti-ocaml
      # php = {
      #   symbol = " "; # nf-seti-php
      # };
      perl = {
        symbol = " "; # nf-seti-perl
        style = "bold bright-green";
      };
      purescript.symbol = " "; # nf-seti-purescript
      python.symbol = " "; # nf-seti-python
      rlang.symbol = " "; # nf-seti-r
      ruby.symbol = " "; # nf-seti-ruby
      rust.symbol = " "; # nf-seti-rust
      scala = {
        symbol = " "; # nf-seti-scala
        style = "red";
      };
      # swift = {
      #   symbol = " "; # nf-seti-swift
      #   style = "";
      # };
      vlang.symbol = " "; # nf-custom-v_lang
      zig.symbol = " "; # nf-seti-zig
    };

    # custom.gitfetch = {
    #   command = "${pkgsUnstable.onefetch}/bin/onefetch";
    #   require_repo = true;
    # };
  };
}
