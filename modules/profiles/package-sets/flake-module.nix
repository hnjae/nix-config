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
    user-dev = (import ./sets/user-dev.nix) arg;
    user-home = (import ./sets/user-home.nix) arg;
    user-desktop = (import ./sets/user-home.nix) arg;
    user-desktop-nixos = (import ./sets/user-desktop-nixos.nix) arg;
  };
  flake.overlays.unstable = _: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev) system;
      config = prev.config;
    };
  };
}
