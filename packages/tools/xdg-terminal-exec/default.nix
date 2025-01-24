{
  writeScriptBin,
  alacritty,
  dash,
}:
let
  terminal = "${alacritty}/bin/alacritty";
in
writeScriptBin "xdg-terminal-exec" ''
  #!${dash}/bin/dash

  [ -z "$@" ] && exec "${terminal}" </dev/null ||
    exec ${terminal} --class "$1" --title "$1" -e "$@" </dev/null
''
