{
  pkgs ? import <nixpkgs> { },
}:
let
  lib = pkgs.lib;
in
pkgs.writeScriptBin "set-charge-threshold" (
  let
    path = lib.makeBinPath (
      with pkgs;
      [
        uutils-coreutils-noprefix
      ]
    );
  in
  (lib.concatLines [
    (''
      #!${pkgs.dash}/bin/dash

      PATH=${path}
    '')
    (builtins.readFile ./set-charge-threshold.sh)
  ])
)
