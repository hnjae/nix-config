{ inputs, localFlake, ... }:
_: {
  nixpkgs.overlays = [
    localFlake.overlays.default
    inputs.rust-overlay.overlays.default
  ];
  nixpkgs.config.allowUnfree = true;
}
