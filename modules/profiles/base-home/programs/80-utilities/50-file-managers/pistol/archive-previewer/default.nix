{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage (
  {
    python3,
    stdenv,
  }:
  stdenv.mkDerivation {
    name = "archive-previewer";
    propagatedBuildInputs = [
      (python3.withPackages (
        ps:
        (with ps; [
          rarfile
          tabulate
          python-magic
        ])
      ))
    ];
    dontUnpack = true;
    installPhase = "install -Dm555 ${./archive-previewer.py} $out/bin/archive-previewer";
  }
) { }
