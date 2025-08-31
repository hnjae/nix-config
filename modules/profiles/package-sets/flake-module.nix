{
  flake-parts-lib,
  inputs,
  self,
  ...
}:
let
  opts = {
    localFlake = self;
    inherit inputs;
    inherit flake-parts-lib;
    inherit (inputs) nixpkgs-unstable;
    lib = inputs.nixpkgs.lib;
  };
in
{
  flake.packageSets = {
    dev = (import ./dev.nix) opts;
    sbin = (import ./sbin.nix) opts;
  };
}
