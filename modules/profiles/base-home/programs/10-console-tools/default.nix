{ pkgs, pkgsUnstable, ... }:
{
  imports = [
    ./bat.nix
    ./cheat.nix
    ./eza.nix
    ./fzf.nix
    ./git
    ./jq.nix
    ./just.nix
    ./navi
    ./pueue.nix
  ];

  home.packages = [
    # man pages
    pkgs.man-pages
    pkgs.man-pages-posix

    pkgs.fd
    pkgs.ripgrep
    pkgs.ripgrep-all # ripgrep & PDF E-Books & Office documents & etc.
    pkgs.sd # 'modern' sed
    pkgs.delta # replace diff
    pkgsUnstable.hexyl # replace od
    pkgsUnstable.procs # replace ps
    pkgsUnstable.viddy # replace watch

    pkgsUnstable.mprocs # run mutliple commands in parallel

    pkgsUnstable.yq # sed for json/yaml
    pkgsUnstable.du-dust # dust(du)
    pkgsUnstable.gping # gping(ping)
    pkgsUnstable.doggo # doqqg(dig)
  ];
}
