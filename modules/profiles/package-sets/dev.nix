{
  inputs,
  lib,
  nixpkgs-unstable,
  ...
}:
pkgs:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config = {
      inherit (pkgs.config) allowUnfree;
    };
  };
in

lib.flatten [
  inputs.yaml2nix.packages.${pkgs.system}.default
  pkgs.gcc
  pkgs.gnumake
  pkgs.cmake

  pkgsUnstable.editorconfig-checker
  pkgsUnstable.harper # grammar checker for developers
  pkgsUnstable.vale
]
