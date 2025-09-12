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
  # Git                #
  ######################
  pkgs.git-open
  pkgs.git-filter-repo
  pkgs.git-crypt
  pkgs.git-lfs
  pkgs.unstable.lazygit

  ######################
  # nix                #
  ######################
  (with pkgs.unstable; [
    nil # lsp
    # nixpkgs-lint # nix linter
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
  # pkgs.deploy-rs
  inputs.deploy-rs.packages.${pkgs.system}.default
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
  pkgs.unstable.basedpyright

  ######################
  # Lua                #
  ######################
  pkgs.lua
  (with pkgs.unstable; [
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
  pkgs.texlivePackages.tex
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
  # typst              #
  ######################
  pkgs.unstable.typst
  pkgs.unstable.tinymist
  pkgs.unstable.typstfmt

  ######################
  # DB                 #
  ######################
  pkgs.mongosh
  pkgs.sqlite
  pkgs.postgresql_17

  ######################
  # Neovim             #
  ######################
  # treesitter 을 시스템 단위로 관리하고 싶지 않으니, home-manager 모듈은 사용하지 말 것.
  pkgs.unstable.neovim
  pkgs.unstable.neovim-remote
  pkgs.unstable.code-minimap
  pkgs.unstable.tree-sitter
  pkgs.unstable.universal-ctags
  pkgs.libsecret # to access org.freedesktop.Secret.Service in neovim config
  # pkgsUnstable.glrnvim
  # pkgs.gnvim
  # neovim-qt # 한글 입력 별로. 사용하지 말것 (2024-04-18)
  # neovim-gtk # IME 입력에서 도중 결과가 출력되지 않음 (2025-07-07)
  # neovide # IME 입력에서 도중 결과가 출력되지 않음 (2025-07-07)
  # pkgs.page # use neovim as pager; not working 2025-07-13
  # pkgs.nvimpager # use neovim as pager
  (lib.hiPrio (
    pkgs.makeDesktopItem {
      name = "nvim";
      desktopName = "Neovim";
      genericName = "Text Editor";
      icon = "nvim";
      exec = ''${pkgs.wezterm}/bin/wezterm start --class=nvim -e nvim %F'';
      # tryExec = ''${pkgs.wezterm}/bin/wezterm start --class=nvim -e nvim''; # 이유는 모르겠으나, tryExec 이 있으면 KDE 가 인식을 못함. <NixOS 25.05>
      categories = [
        "Utility"
        "TextEditor"
      ];
      keywords = [
        "Text"
        "editor"
      ];
    }
  ))
  (lib.hiPrio (
    pkgs.runCommandLocal "nvim-icon-fix" { } ''
      mkdir -p "$out/share/icons/hicolor/scalable/apps/"

      # icon='${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/io.neovim.nvim.svg'
      icon='${pkgs.whitesur-icon-theme}/share/icons/WhiteSur/apps/scalable/nvim.svg'
      app_id='nvim'

      cp --reflink=auto \
      "$icon" \
      "$out/share/icons/hicolor/scalable/apps/''${app_id}.svg"

      for size in 16 22 24 32 48 64 96 128 256 512; do
        mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps/"
          '${pkgs.librsvg}/bin/rsvg-convert' \
          --keep-aspect-ratio \
          --height="$size" \
          --output="$out/share/icons/hicolor/''${size}x''${size}/apps/''${app_id}.png" \
          "$icon"
      done
    ''
  ))

  ######################
  # Vscode             #
  ######################
  pkgs.unstable.vscode-fhs

  ######################
  # Misc               #
  ######################
  pkgs.go
  pkgs.ansible
  pkgs.unstable.nufmt
  pkgs.rust-bin.stable.latest.default
  pkgs.unstable.taplo # lsp for toml written in rust
  pkgs.unstable.yaml-language-server
  pkgs.unstable.yamlfmt
  (pkgs.runCommandLocal "vscode-json-language-server" { } ''
    mkdir -p $out/bin
    ln -s "${pkgs.unstable.vscode-langservers-extracted}/bin/vscode-json-language-server" "$out/bin/vscode-json-language-server"
  '')
  pkgs.unstable.hurl

  pkgs.unstable.leetcode-cli
  pkgs.unstable.tinty # Base16 and base24 color scheme manager
  pkgs.unstable.mani # <https://github.com/alajmo/mani>
  pkgs.unstable.awscli2
  pkgs.unstable.dotbot
  pkgs.unstable.buildah
  pkgs.unstable.openssl

  ######################
  # 테스트 中
  ######################
  pkgs.unstable.k6 # A modern load testing tool, using Go and JavaScript
  pkgs.unstable.hyperfine # command-line benchmarking tool
  pkgs.unstable.gtt # can use chatgpt to translate <https://github.com/eeeXun/gtt>
  pkgs.unstable.tgpt # support openai, ollma https://github.com/aandrew-me/tgpt
  pkgs.unstable.gh # github cli
  pkgs.unstable.gh-copilot
  pkgs.unstable.patchelfStable

])
