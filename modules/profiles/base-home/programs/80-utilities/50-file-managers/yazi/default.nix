{ pkgsUnstable, ... }:
let
  cdPosix = builtins.readFile ./resources/yazi-cd.sh;
in
{
  programs.yazi = {
    enable = true;
    package = pkgsUnstable.yazi;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = false;
  };

  programs.zsh.initExtra = cdPosix;
  programs.bash.initExtra = cdPosix;
  programs.fish.functions.yazicd = {
    body = builtins.readFile ./resources/yazi-cd.fish;
    description = "yazi wrapper";
  };

  home.shellAliases.y = "yazicd";
}
