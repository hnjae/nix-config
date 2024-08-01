{
  config,
  pkgs,
  ...
}: let
  # cheatPath = "${config.xdg.dataHome}/navi/cheats/my_cheats";
  posixSh = builtins.readFile ./share/navi.sh;

  babelfishTranslate = path: name:
    pkgs.runCommandLocal "${name}.fish" {
      nativeBuildInputs = [pkgs.babelfish];
    } "babelfish < ${path} > $out;";
in {
  # navi
  programs.zsh.initExtra = posixSh;
  programs.bash.initExtra = posixSh;
  # programs.fish.interactiveShellInit =
  #   builtins.readFile (babelfishTranslate
  #     ./navi.sh "navi");
}
