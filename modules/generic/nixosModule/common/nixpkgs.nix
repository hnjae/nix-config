{
  inputs,
  self,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nur.overlays.default
    self.overlays.default
  ];
}
