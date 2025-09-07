{
  pkgs ? import <nixpkgs> { },
}:
pkgs.kdePackages.callPackage ./derivation.nix { }
