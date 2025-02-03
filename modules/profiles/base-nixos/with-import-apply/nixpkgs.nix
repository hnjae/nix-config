{ localFlake, ... }:
_: {
  nixpkgs.overlays = [
    localFlake.overlays.default
  ];
  nixpkgs.config.allowUnfree = true;
}
