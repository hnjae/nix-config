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
  pkgs.powertop
]
