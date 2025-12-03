{ inputs, lib, ... }:
pkgs:
lib.flatten [
  (lib.lists.optional (
    inputs.py-utils ? packages
  ) inputs.py-utils.packages.${pkgs.stdenv.hostPlatform.system}.default)
]
