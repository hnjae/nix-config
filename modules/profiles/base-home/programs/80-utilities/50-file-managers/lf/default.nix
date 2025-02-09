{ pkgs, pkgsUnstable, ... }:
let
  lfcdPosix = builtins.readFile ./resources/lfcd.sh;
in
{
  home.packages = [
    pkgsUnstable.lf
    pkgsUnstable.chafa
    pkgsUnstable.imagemagick
    (pkgs.runCommandLocal "papers-thumbnailer" { } ''
      mkdir -p "$out/bin"
      ln -s "${pkgs.papers}/bin/papers-thumbnailer" "$out/bin/papers-thumbnailer"
    '')
    pkgs.epub-thumbnailer
    pkgs.gnome-epub-thumbnailer # for epub & mobi
  ];

  programs.zsh.initExtra = lfcdPosix;
  programs.bash.initExtra = lfcdPosix;
  programs.fish.functions.lfcd = {
    body = builtins.readFile ./resources/lfcd.fish;
    description = "lf wrapper";
  };

  home.shellAliases.lf = "lfcd";

  python = {
    enable = true; # my config file uses python script
  };
}
