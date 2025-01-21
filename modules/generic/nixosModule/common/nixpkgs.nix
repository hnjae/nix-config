{self, ...}: {
  nixpkgs.overlays = [
    self.overlays.default
  ];

  nixpkgs.config.allowUnfree = true;
}
