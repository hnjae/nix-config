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

      rmlint

      xxHash
      rsbkb # crc32 / hex

      payload-dumper-go

      dos2unix

      speedtest-rs
    ])
    (with pkgsUnstable; [
      yt-dlp
      ouch
      vimv-rs # cyclic-renaming 지원, 엣지 케이스 대응 잘함.
    ])
    (lib.lists.optionals pkgs.stdenv.isLinux [
      pkgs.convmv
      pkgs.poppler_utils # pdftotext
      pkgs.clipboard-jh
    ])
  ];

  home.shellAliases = {
    t = "tmux";
  };

  programs.nh.enable = true;
}
