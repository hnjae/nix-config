# https://github.com/ibraheemdev/modern-unix

{
  config,
  pkgs,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  imports = [
    ./pistol
    ./pueue.nix
    ./qalc.nix
    ./tldr.nix
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = lib.flatten [
    pkgs.ranger
    pkgsUnstable.joshuto
    (lib.hiPrio (
      pkgs.makeDesktopItem {
        name = "joshuto";
        desktopName = "joshuto";
        genericName = "File Manager";
        icon = "system-file-manager";
        mimeTypes = [ "inode/directory" ];
        exec = ''${pkgs.wezterm}/bin/wezterm start --class=joshuto -e joshuto'';
        categories = [
          "System"
          "FileTools"
          "FileManager"
        ];
        keywords = [
          "File"
          "Manager"
          "Browser"
          "Explorer"
        ];
      }
    ))
    # (pkgs.runCommandLocal "add-joshuto-icon" { } ''
    #   mkdir -p "$out/share/icons/hicolor/scalable/apps/"
    #
    #   cp --reflink=auto \
    #     "${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/rpminstall.svg" \
    #     "$out/share/icons/hicolor/scalable/apps/joshuto.svg"
    # '')

    pkgs.rsync
    pkgs.oh-my-posh
    pkgs.starship

    pkgs.eza # lsd 는 ANSI color 안써서 eza 쓰자. <2023-10-05; lsd v0.23.1>
    pkgs.duf

    pkgs.pfetch-rs
    pkgsUnstable.fzf

    pkgs.zoxide
    pkgs.any-nix-shell

    # man pages
    pkgs.man-pages
    pkgs.man-pages-posix

    pkgs.fd
    pkgs.ripgrep
    pkgs.ripgrep-all # ripgrep & PDF E-Books & Office documents & etc.
    pkgs.sd # 'modern' sed
    pkgs.delta # replace diff
    pkgs.tree
    pkgs.hexyl # replace od
    pkgs.procs # replace ps
    pkgs.viddy # replace watch
    pkgs.jq
    pkgs.yq # sed for json/yaml
    pkgs.bat

    pkgs.cheat
    pkgs.navi

    pkgs.mprocs # run multiple commands in parallel
    # pkgsUnstable.tinty # https://github.com/tinted-theming/tinty (base24 / base16)

    # NOTE: trashy is not usable because of following issue: https://github.com/Byron/trash-rs/issues/57 <2023-03-22>
    # pkgs.trashy # trash-cli alternative in rust
    pkgs.trash-cli
    pkgs.tmux
    # pkgs.tmuxinator
    pkgs.uuid7

    # pkgs.du-dust # dust(du)
    # pkgs.gping # gping(ping)
    # pkgs.doggo # doggo(dig)

    # Git
    pkgs.git-open
    pkgs.git-filter-repo
    pkgs.git-crypt
    pkgs.git-lfs
    pkgsUnstable.lazygit
    # commitlint
    # gitlint # broken 2025-04-09
    # gitleaks
    # git-annex
    # bup
    # gitu # it freezes

    pkgsUnstable.just

    pkgs.nh # nix wrapper
    pkgs.cht-sh

    pkgs.xxHash
    pkgs.rsbkb # crc32 / hex

    pkgs.fio
    pkgs.fclones
    pkgs.rmlint
    pkgs.dos2unix
    pkgs.speedtest-rs

    pkgs.ouch # archive handler
    pkgs.vimv-rs # cyclic-renaming 지원, 엣지 케이스 대응 잘함.

    pkgs.kmon # linux kernel activity monitor

    pkgs.btop
    (lib.hiPrio (
      pkgs.makeDesktopItem {
        name = "btop";
        desktopName = "btop++";
        genericName = "System Monitor";
        icon = "btop";
        # exec = ''${pkgs.wezterm}/bin/wezterm --config="color_scheme=\\"Kanagawa Dragon (Gogh)\\"" start --class=btop -e btop'';
        exec = ''${pkgs.wezterm}/bin/wezterm start --class=btop -e btop'';
        categories = [
          "System"
          "Monitor"
        ];
        keywords = [
          "system"
          "process"
          "task"
        ];
      }
    ))

    pkgs.htop
    (lib.hiPrio (
      pkgs.makeDesktopItem {
        name = "htop";
        desktopName = "Htop";
        genericName = "Process Viewer";
        icon = "htop";
        exec = ''${pkgs.wezterm}/bin/wezterm start --class=htop -e htop'';
        categories = [
          "System"
          "Monitor"
        ];
        keywords = [
          "system"
          "process"
          "task"
        ];
      }
    ))

    pkgsUnstable.lazydocker

    pkgsUnstable.yt-dlp
    pkgsUnstable.rclone
    pkgsUnstable.rustic

    (lib.lists.optionals pkgs.stdenv.isLinux [
      pkgs.convmv
      pkgs.poppler_utils # pdftotext
    ])
    (lib.lists.optionals (pkgs.stdenv.isLinux && baseHomeCfg.isDesktop) [
      pkgs.clipboard-jh
      pkgs.handlr-regex
      (pkgs.runCommandLocal "gtk-launch" { } ''
        mkdir -p "$out/bin"
        ln -s "${pkgs.gtk3}/bin/gtk-launch" "$out/bin/gtk-launch"
      '')
    ])

    # Fancy
    pkgsUnstable.fastfetch # C, count nix pckage
    pkgsUnstable.cpufetch
    pkgsUnstable.ipfetch
    pkgsUnstable.onefetch # git
    (lib.lists.optional pkgs.stdenv.isLinux pkgsUnstable.ramfetch)

  ];
}
