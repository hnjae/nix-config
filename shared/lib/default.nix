{
  mountpathToUnit =
    mountpath:
    "${
      builtins.substring 1 (-1) (builtins.replaceStrings [ "-" "/" ] [ "\\x2d" "-" ] mountpath)
    }.mount";

  rusticIgnoreFileFactory = import ./rustic-ignorefile-factory.nix;
}
