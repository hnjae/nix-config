{
  mountpathToUnit =
    mountpath:
    "${
      builtins.substring 1 (-1) (builtins.replaceStrings [ "-" "/" ] [ "\\x2d" "-" ] mountpath)
    }.mount";

  rusticIgnoreFileFactory = import ./lib/rustic-ignorefile-factory.nix;

}
