{
  pkgs,
  pkgsUnstable,
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  # treesitter 을 시스템 단위로 관리하고 싶지 않으니, home-manager 모듈은 사용하지 말 것.
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = lib.flatten [
      (with pkgsUnstable; [
        neovim
        neovim-remote
        code-minimap
        tree-sitter
        libsecret # to access org.freedesktop.Secret.Service in neovim config
        tinty
      ])

      (lib.lists.optionals baseHomeCfg.isDesktop ([
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
            # mimeTypes = [
            #   "text/plain"
            #   "application/x-shellscript" # {'*.sh'}
            #   "text/x-tex" # {'*.dtx', '*.tex', '*.sty', '*.cls', '*.ltx', '*.latex', '*.ins'}
            #   "text/x-java" # {'*.java'}
            # ];
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
          # icon='${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/io.neovim.nvim.svg'
          pkgs.runCommandLocal "nvim-icon-fix" { } ''
            mkdir -p "$out/share/icons/hicolor/scalable/apps/"

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
      ]))
    ];

    default-app.text = "nvim";

    home.sessionVariables = {
      EDITOR = lib.mkForce "nvim";
      VISUAL = "nvim";
    };
  };
}
