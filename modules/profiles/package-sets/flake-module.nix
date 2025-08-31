{
  flake-parts-lib,
  inputs,
  self,
  ...
}:
let
  arg = {
    localFlake = self;
    inherit inputs;
    inherit flake-parts-lib;
    inherit (inputs.nixpkgs) lib;
  };
in
{
  flake.packageSets = {
    system = (import ./sets/system.nix) arg;

    user = (import ./sets/user.nix) arg;
    desktop = (import ./sets/desktop.nix) arg;
    dev = (import ./sets/dev.nix) arg;

    home = (import ./sets/home.nix) arg;
  };
  flake.overlays.unstable = _: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev) system;
      config = prev.config;
    };
  };
}
