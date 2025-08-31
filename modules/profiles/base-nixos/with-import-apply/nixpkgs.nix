{ inputs, localFlake, ... }:
_: {
  nixpkgs.overlays = [
    localFlake.overlays.default
    localFlake.overlays.unstable
    inputs.rust-overlay.overlays.default
  ];
  nixpkgs.config.allowUnfree = true;
}
