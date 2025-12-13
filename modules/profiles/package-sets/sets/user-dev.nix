{
  inputs,
  lib,
  ...
}:
pkgs:
(
  let
    inherit (pkgs.stdenv) hostPlatform;
    inherit (pkgs.config) allowUnfree;
  in
  lib.flatten [
    pkgs.gcc
    pkgs.gnumake
    pkgs.cmake

    pkgs.unstable.editorconfig-checker
    pkgs.unstable.harper # grammar checker for developers

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
    pkgs.unstable.nil # lsp
    # pkgs.unstable.nixpkgs-lint # nix linter
    pkgs.unstable.statix # nix linter
    pkgs.unstable.deadnix # nix linter
    pkgs.unstable.nixfmt-rfc-style # nix formatter
    pkgs.unstable.hydra-check
    pkgs.unstable.shellify # make shell.nix, flake.nix based on nix-shell
    pkgs.unstable.nurl # create nix fetche calls from repository URLs
    pkgs.unstable.nix-init # auto-generate nix stderivation
    # pkgs.unstable.comma # run nixpkgs' pkg with , (comma) (use nix-index-database's)
    pkgs.sops
    # pkgs.deploy-rs
    inputs.deploy-rs.packages.${hostPlatform.system}.default
    inputs.yaml2nix.packages.${hostPlatform.system}.default

    ######################
    # bash
    ######################
    pkgs.unstable.checkbashisms
    pkgs.unstable.shellharden
    pkgs.unstable.shfmt
    pkgs.unstable.beautysh
    pkgs.unstable.shellcheck # shellcheck is deprecated over bashls in none-ls
    pkgs.unstable.bash-language-server

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
    pkgs.unstable.selene
    pkgs.unstable.stylua
    pkgs.unstable.lua-language-server

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
    pkgs.texliveFull
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
    ])
    pkgs.asciidoctor-with-extensions

    ######################
    # typst              #
    ######################
    pkgs.unstable.typst
    pkgs.unstable.tinymist
    # pkgs.unstable.typstyle

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
    pkgs.unstable.tree-sitter # tree-sitter is required to install parsers (2025-10-01)
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
      let
        # NOTE: 여기서 PATH 가 user 가 사용하는 PATH 를 지정하고 싶은데 방법이 읎는 것 같음. <2025-09-14>
        # wrapper = pkgs.writeScript "nvim-terminal-wrapper" ''
        #   #!${pkgs.dash}/bin/dash
        #
        #   PATH="$1"
        #
        #   [ "$1" != "" ] && cwd="$1" || cwd="$HOME"
        #   [ -f "$1" ] && cwd="$(dirname "$1")"
        #
        #   exec wezterm start --class=nvim --cwd="$path" -e nvim "$1"
        # '';
      in
      pkgs.makeDesktopItem {
        name = "nvim";
        desktopName = "Neovim";
        genericName = "Text Editor";
        icon = "nvim";
        exec = ''wezterm start --class=nvim -e nvim %F'';
        categories = [
          "Utility"
          "TextEditor"
        ];
        keywords = [
          "Text"
          "editor"
        ];
      }
      # tryExec: 이유는 모르겠으나, tryExec 이 있으면 KDE 가 인식을 못함. <NixOS 25.05>

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
    # Misc               #
    ######################
    pkgs.go
    pkgs.unstable.nufmt
    # pkgs.rust-bin.stable.latest.default
    pkgs.pkgs.unstable.taplo # lsp for toml written in rust
    pkgs.unstable.yaml-language-server
    # pkgs.unstable.yamlfmt # `>-` 구문 처리에 버그 있는 듯. <2025-09-16>
    # (pkgs.runCommandLocal "vscode-json-language-server" { } ''
    #   mkdir -p $out/bin
    #   ln -s "${pkgs.unstable.vscode-langservers-extracted}/bin/vscode-json-language-server" "$out/bin/vscode-json-language-server"
    # '')
    pkgs.unstable.hurl
    pkgs.unstable.leetcode-cli
    pkgs.unstable.tinty # Base16 and base24 color scheme manager
    pkgs.unstable.mani # <https://github.com/alajmo/mani>
    pkgs.unstable.awscli2
    pkgs.unstable.dotbot
    pkgs.unstable.buildah
    pkgs.unstable.openssl

    ######################
    # LLM
    ######################
    pkgs.unstable.claude-code
    pkgs.unstable.claude-monitor
    (lib.lists.optional allowUnfree
      inputs.claude-desktop.packages.${hostPlatform.system}.claude-desktop-with-fhs
    )

    ######################
    # 테스트 中
    ######################
    pkgs.unstable.k6 # A modern load testing tool, using Go and JavaScript
    pkgs.unstable.hyperfine # command-line benchmarking tool
    pkgs.unstable.gtt # can use chatgpt to translate <https://github.com/eeeXun/gtt>
    pkgs.unstable.tgpt # support openai, ollma https://github.com/aandrew-me/tgpt
    pkgs.unstable.gh # github cli
    pkgs.unstable.patchelf
    pkgs.jqp # TUI playground to experiment with jq
    pkgs.unstable.codex # openai
    pkgs.unstable.gemini-cli-bin
    pkgs.unstable.opencode
    pkgs.unstable.gh-copilot
  ]
)
