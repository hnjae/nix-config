{ pkgs, ... }:
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
    pkgs.tree
    pkgs.hexyl # replace od
    pkgs.procs # replace ps
    pkgs.viddy # replace watch
    pkgs.yq # sed for json/yaml

    pkgs.mprocs # run multiple commands in parallel
    pkgs.tinty # https://github.com/tinted-theming/tinty (base24 / base16)

    # pkgs.du-dust # dust(du)
    # pkgs.gping # gping(ping)
    # pkgs.doggo # doggo(dig)
  ];
}
