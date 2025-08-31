{ inputs, localFlake, ... }:
{
  nixpkgs = {
    overlays = [
      localFlake.overlays.default
      localFlake.overlays.unstable
      inputs.rust-overlay.overlays.default
    ];
    config.allowUnfree = true;
  };
}
