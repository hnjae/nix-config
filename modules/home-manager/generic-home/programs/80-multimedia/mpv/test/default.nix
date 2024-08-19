# run nix-build
{pkgs ? import <nixpkgs> {}}:
pkgs.callPackage ./package {}
