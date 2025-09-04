{
  inputs,
  lib,
  ...
}:
pkgs:
(lib.flatten [
  inputs.yaml2nix.packages.${pkgs.system}.default
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
    # LSPs
    # rnix-lsp -- dead 2024-03-16
    nixd
    nil

    # nix lintter
    nixpkgs-lint
    statix
    deadnix

    # nix formatter
    nixfmt-rfc-style
    hydra-check
  ])

  ######################
  # bash
  ######################
  (with pkgs.unstable; [
    checkbashisms
    shellharden
    shfmt
    beautysh
    shellcheck

    # shellcheck deprecated over bashls in none-ls
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
  # pkgs.unstable.basedpyright
  pkgs.unstable.ruff # includes lsp via `ruff server`
  pkgs.unstable.uv

  ######################
  # Lua                #
  ######################
  (with pkgs.unstable; [
    lua
    # lua
    selene
    stylua
    sumneko-lua-language-server
  ])

  ######################
  # NodeJS             #
  ######################
  pkgs.unstable.biome # linters, formatters
  pkgs.unstable.pnpm
  pkgs.nodejs_20 # current LTS (2024-02-29)
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
])
