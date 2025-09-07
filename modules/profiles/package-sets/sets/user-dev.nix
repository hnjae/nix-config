{
  inputs,
  lib,
  ...
}:
pkgs:
(lib.flatten [
  pkgs.gcc
  pkgs.gnumake
  pkgs.cmake

  pkgs.unstable.editorconfig-checker
  pkgs.unstable.harper # grammar checker for developers
  pkgs.unstable.vale

  ######################
  # nix                #
  ######################
  (with pkgs.unstable; [
    nil # lsp
    nixpkgs-lint # nix linter
    statix # nix linter
    deadnix # nix linter
    nixfmt-rfc-style # nix formatter
    hydra-check
    shellify # make shell.nix, flake.nix based on nix-shell
    nurl # create nix fetche calls from repository URLs
    nix-init # auto-generate nix stderivation
    # comma # run nixpkgs' pkg with , (comma) (use nix-index-database's)
  ])
  pkgs.sops
  pkgs.deploy-rs
  inputs.yaml2nix.packages.${pkgs.system}.default

  ######################
  # bash
  ######################
  (with pkgs.unstable; [
    checkbashisms
    shellharden
    shfmt
    beautysh
    shellcheck # shellcheck is deprecated over bashls in none-ls
    bash-language-server
  ])

  ######################
  # Python             #
  ######################
  (pkgs.python3.withPackages (
    python-pkgs: with python-pkgs; [
      ipython
      mypy
    ]
  ))
  pkgs.unstable.ruff # includes lsp via `ruff server`
  pkgs.unstable.uv

  ######################
  # Lua                #
  ######################
  (with pkgs.unstable; [
    lua
    selene
    stylua
    sumneko-lua-language-server
  ])

  ######################
  # NodeJS             #
  ######################
  pkgs.unstable.biome # linters, formatters
  pkgs.unstable.pnpm
  pkgs.nodePackages.nodejs
  pkgs.unstable.nest-cli
  pkgs.deno
  pkgs.bun

  #######################
  # Markdown/TeX/etc... #
  #######################
  (with pkgs.unstable; [
    # markdown
    marksman
    markdownlint-cli
    markdownlint-cli2
    cbfmt # format codeblocks inside markdown and org
    mdcat # markdown preview in cli; better than glow as it uses ANSI colors

    # tex/markdown ..
    ltex-ls

    # spellcheck
    codespell # all
    proselint # markdown, tex
    pkgs.write-good # markdown
    # textidote # markdown, tex

    # html formatter
    html-tidy

    # asciidoctor
    asciidoctor-with-extensions
  ])

  ######################
  # DB                 #
  ######################
  pkgs.mongosh
  pkgs.sqlite
  pkgs.postgresql_17

  ######################
  # Misc               #
  ######################
  pkgs.go
  pkgs.unstable.nufmt
  pkgs.rust-bin.stable.latest.default
  pkgs.unstable.taplo # lsp for toml written in rust
  pkgs.unstable.yaml-language-server
  pkgs.unstable.yamlfmt
  (pkgs.runCommandLocal "vscode-json-language-server" { } ''
    mkdir -p $out/bin
    ln -s "${pkgs.unstable.vscode-langservers-extracted}/bin/vscode-json-language-server" "$out/bin/vscode-json-language-server"
  '')
  pkgs.unstable.k6 # A modern load testing tool, using Go and JavaScript
  pkgs.unstable.hurl

  pkgs.unstable.leetcode-cli
])
