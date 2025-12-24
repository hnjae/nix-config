{ localFlake, ... }:
{
  nixpkgs = {
    overlays = [
      localFlake.overlays.default
      localFlake.overlays.unstable
    ];
    config.allowUnfree = true;
  };
}
