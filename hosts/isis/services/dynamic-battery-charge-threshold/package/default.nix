{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
in
pkgs.writeScriptBin "set-charge-threshold" (
  let
    path = lib.makeBinPath (
      with pkgs;
      [
        coreutils
      ]
    );
  in
  lib.concatLines [
    ''
      #!${pkgs.dash}/bin/dash

      PATH=${path}
    ''
    (builtins.readFile ./set-charge-threshold.sh)
  ]
)
