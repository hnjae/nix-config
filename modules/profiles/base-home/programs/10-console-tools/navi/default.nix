{
  pkgsUnstable,
  pkgs,
  ...
}:
let
  # cheatPath = "${config.xdg.dataHome}/navi/cheats/my_cheats";
  posixSh = builtins.readFile ./resources/navi.sh;

  babelfishTranslate =
    path: name:
    pkgs.runCommandLocal "${name}.fish" {
      nativeBuildInputs = [ pkgs.babelfish ];
    } "babelfish < ${path} > $out;";
in
{
  programs.navi = {
    enable = true;
    package = pkgsUnstable.navi;
  };

  home.shellAliases = {
    na = "navi";
    # navi = ''echo "use <C-g> instead"'';
  };

  programs.zsh.initContent = posixSh;
  programs.bash.initExtra = posixSh;
  # programs.fish.interactiveShellInit =
  #   builtins.readFile (babelfishTranslate
  #     ./navi.sh "navi");
}
