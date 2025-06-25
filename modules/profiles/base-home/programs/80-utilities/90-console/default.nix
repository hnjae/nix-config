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
    ./nushell.nix
    ./pueue.nix
    ./qalc.nix
    ./tldr.nix
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = lib.flatten [
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
    pkgsUnstable.tinty # https://github.com/tinted-theming/tinty (base24 / base16)

    # NOTE: trashy is not usable because of following issue: https://github.com/Byron/trash-rs/issues/57 <2023-03-22>
    # pkgs.trashy # trash-cli alternative in rust
    pkgs.trash-cli
    pkgs.tmux
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
    pkgs.stow
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
    pkgsUnstable.lazydocker

    pkgsUnstable.yt-dlp
    pkgsUnstable.rclone
    pkgsUnstable.rustic

    (lib.lists.optionals pkgs.stdenv.isLinux [
      pkgs.convmv
      pkgs.poppler_utils # pdftotext
      pkgs.clipboard-jh
    ])
    (lib.lists.optionals baseHomeCfg.isDesktop [ pkgs.handlr-regex ])

    # Fancy
    pkgsUnstable.fastfetch # C, count nix pckage
    pkgsUnstable.cpufetch
    pkgsUnstable.ipfetch
    pkgsUnstable.onefetch # git
    (lib.lists.optionals pkgs.stdenv.isLinux [ pkgsUnstable.ramfetch ])
  ];
}
