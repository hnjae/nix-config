# run `nix-build`
{
  pkgs ? import <nixpkgs> { },
  pkgsUnstable ? import <nixpkgs-unstable> { },
}:
pkgs.libsForQt5.callPackage (
  {
    mkDerivation,
    lib,
    libarchive,
    yacreader,
    libunarr,
    qtimageformats,
    kimageformats,
  }:
  mkDerivation {
    inherit (pkgsUnstable.yacreader) src version pname;

    inherit (yacreader)
      meta
      nativeBuildInputs
      propagatedBuildInputs
      ;

    buildInputs = (lib.lists.remove libunarr yacreader.buildInputs) ++ [
      libarchive
      qtimageformats
      kimageformats
    ];
    qmakeFlags = [ ''CONFIG+=libarchive'' ];
  }
) { }
