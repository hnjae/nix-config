{
  mountpathToUnit =
    mountpath:
    "${
      builtins.substring 1 (-1) (
        builtins.replaceStrings [ " " "-" "/" ] [ "\\x20" "\\x2d" "-" ] mountpath
      )
    }.mount";

  pathToUnit =
    path:
    "${builtins.substring 1 (-1) (
      builtins.replaceStrings [ " " "-" "/" ] [ "\\x20" "\\x2d" "-" ] path
    )}";
  # OR use following instead "${
  #   builtins.substring 1 (-1) (
  #     builtins.replaceStrings [ "/" ] [ "-" ] (lib.strings.escapeC [ "-" ] (path))
  #   )
  # }"

  rusticIgnoreFileFactory = import ./rustic-ignorefile-factory.nix;
}
