{
  inputs,
  lib,
  ...
}:
pkgs:
(lib.flatten [
  inputs.yaml2nix.packages.${pkgs.system}.default
  pkgs.gcc
  pkgs.gnumake
  pkgs.cmake

  pkgs.unstable.editorconfig-checker
  pkgs.unstable.harper # grammar checker for developers
  pkgs.unstable.vale
])
