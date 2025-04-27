# https://github.com/ibraheemdev/modern-unix

{
  pkgs,
  lib,
  pkgsUnstable,
  ...
}:
{
  imports = [
    ./99-fancy.nix

    ./bottom.nix
    ./duf.nix
    ./qalc.nix
    ./rsync.nix
    ./tldr
    ./tmux.nix
  ];

  home.packages = builtins.concatLists [
    (with pkgs; [
      # NOTE: trashy is not usable because of following issue: https://github.com/Byron/trash-rs/issues/57 <2023-03-22>
      # trashy # trash-cli alternative in rust
      trash-cli

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

  programs.nh.enable = true; # nix wrapper
}
