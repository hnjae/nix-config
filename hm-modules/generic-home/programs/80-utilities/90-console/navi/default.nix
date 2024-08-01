{pkgsUnstable, ...}: {
  imports = [./functions.nix];

  programs.navi = {
    enable = true;
    package = pkgsUnstable.navi;
  };

  home.shellAliases = {
    # navi = ''echo "use <C-g> instead"'';
  };
}
