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
        nvimWrapper = pkgs.writeScript "nvim-wrapper" ''
          #!${pkgs.dash}/bin/dash

          if [ -n "$1" ]; then
            # 파일이 전달된 경우, 해당 파일의 부모 디렉토리를 working directory로 설정
            file_path="$1"
            if [ -f "$file_path" ]; then
              work_dir="$(dirname "$file_path")"
            else
              work_dir="$HOME"
            fi
          else
            # 파일이 전달되지 않은 경우 홈 디렉토리 사용
            work_dir="$HOME"
          fi

          exec alacritty \
            --class=nvim,nvim \
            --command=nvim \
            --title="Neovim" \
            --working-directory="$work_dir" \
            "$@"
        '';
      in
      pkgs.makeDesktopItem rec {
        name = "nvim";
        desktopName = "Neovim";
        genericName = "Text Editor";
        icon = "nvim";
        # exec = "${nvimWrapper} %F";
        exec = builtins.concatStringsSep " " [
          "alacritty"
          "--class=nvim"
          "--title=${desktopName}"
          # "--working-directory="
          "-e"
          "nvim"
          "%F"
        ];
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

    #######################################
    # Other formatters, linters, ... etc
    #######################################
    pkgs.unstable.prek # pre-commit-hook
    pkgs.unstable.taplo # lsp for toml written in rust
    pkgs.unstable.typos # source code spell checker
    pkgs.unstable.yamlfix
    # pkgs.unstable.yamlfmt

    ######################
    # Misc               #
    ######################
    pkgs.go
    pkgs.unstable.yaml-language-server
    pkgs.unstable.hurl
    pkgs.unstable.leetcode-cli
    pkgs.unstable.tinty # Base16 and base24 color scheme manager
    pkgs.unstable.mani # <https://github.com/alajmo/mani>
    pkgs.unstable.awscli2
    pkgs.unstable.buildah # build oci container images
    pkgs.unstable.openssl

    ######################
    # LLM
    ######################
    pkgs.unstable.claude-monitor
    (lib.lists.optionals allowUnfree [
      pkgs.unstable.claude-code
      inputs.claude-desktop.packages.${hostPlatform.system}.claude-desktop-with-fhs
    ])
    pkgs.unstable.codex # openai
    pkgs.unstable.opencode

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
    pkgs.unstable.gemini-cli-bin
    pkgs.unstable.gh-copilot
  ]
)
