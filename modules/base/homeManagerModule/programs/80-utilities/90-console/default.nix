{
  pkgs,
  lib,
  pkgsUnstable,
  ...
}:
{
  imports = [
    ./99-fancy.nix
    ./99-modern-utils.nix
    ./eza.nix
    ./bat.nix
    ./bottom.nix
    ./cheat.nix
    ./duf.nix
    ./jq.nix
    ./just.nix
    ./navi
    ./tldr
    ./zellij
    ./qalc.nix
    ./fzf.nix
    ./rsync.nix
  ];

  # https://github.com/ibraheemdev/modern-unix
  home.packages = builtins.concatLists [
    (with pkgs; [
      # NOTE: trashy is not usable because of following issue: https://github.com/Byron/trash-rs/issues/57 <2023-03-22>
      # trashy # trash-cli alternative in rust
      trash-cli

      stow
      cht-sh

      tmux

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
      cheat
      ouch
    ])
    (lib.lists.optionals pkgs.stdenv.isLinux [ pkgs.convmv ])
  ];
  home.shellAliases = {
    t = "tmux";
  };

  programs.nh.enable = true;
}
