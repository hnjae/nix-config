{ pkgsUnstable, ... }:
let
  lfcdPosix = builtins.readFile ./resources/lfcd.sh;
in
{
  home.packages = with pkgsUnstable; [
    lf
    chafa
    imagemagick
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
