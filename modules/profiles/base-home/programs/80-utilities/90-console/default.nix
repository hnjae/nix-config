# https://github.com/ibraheemdev/modern-unix

{
  pkgs,
  lib,
  pkgsUnstable,
  config,
  ...
}:
{
  imports = [
    ./99-fancy.nix

    ./bottom.nix
    ./direnv.nix
    ./nushell.nix
    ./pueue.nix
    ./qalc.nix
    ./tldr.nix
  ];

  home.packages = lib.flatten [
    pkgs.rsync
    pkgs.oh-my-posh
    pkgs.starship

    # NOTE: trashy is not usable because of following issue: https://github.com/Byron/trash-rs/issues/57 <2023-03-22>
    # pkgs.trashy # trash-cli alternative in rust
    pkgs.trash-cli
    pkgs.tmux
    pkgs.uuid7

    pkgs.eza # lsd 는 ANSI color 안써서 eza 쓰자. <2023-10-05; lsd v0.23.1>
    pkgs.duf

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

    # pkgs.du-dust # dust(du)
    # pkgs.gping # gping(ping)
    # pkgs.doggo # doggo(dig)

    # Git
    pkgs.git-open
    pkgs.git-filter-repo
    pkgs.git-crypt
    pkgs.git-lfs
    pkgs.lazygit
    # commitlint
    # gitlint # broken 2025-04-09
    # gitleaks
    # git-annex
    # bup
    # gitu # it freezes

    pkgs.pfetch-rs
    pkgsUnstable.just
    pkgsUnstable.fzf

    pkgs.zoxide
    pkgs.any-nix-shell

    pkgs.nh # nix wrapper
    (with pkgs; [
      stow
      cht-sh

      fio

      fclones
      rmlint

      xxHash
      rsbkb # crc32 / hex

      dos2unix
      speedtest-rs

      ouch # archive handler
      vimv-rs # cyclic-renaming 지원, 엣지 케이스 대응 잘함.

      kmon # linux kernel activity monitor
      btop

    ])
    (with pkgsUnstable; [
      yt-dlp
      rclone
      restic
      rustic
    ])
    (lib.lists.optionals pkgs.stdenv.isLinux [
      pkgs.convmv
      pkgs.poppler_utils # pdftotext
      pkgs.clipboard-jh
    ])
  ];
}
