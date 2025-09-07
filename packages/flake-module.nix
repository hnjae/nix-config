{
  inputs,
  self,
  withSystem,
  ...
}:
let
  eachSystem =
    systems: module:
    (inputs.nixpkgs.lib.attrsets.mergeAttrsList (map (system: withSystem system module) systems));
in
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      packages = {
        fonts-dmca-sans-serif = (import ./fonts/fonts-dmca-sans-serif) { inherit pkgs; };
        fonts-freesentation = (import ./fonts/fonts-freesentation) { inherit pkgs; };
        fonts-plangothic = (import ./fonts/fonts-plangothic) { inherit pkgs; };
        fonts-ridibatang = (import ./fonts/fonts-ridibatang) { inherit pkgs; };

        # unfree
        fonts-kopub-world = (import ./fonts/fonts-kopub-world) { inherit pkgs; };
        fonts-toss-face = (import ./fonts/fonts-toss-face) { inherit pkgs; };
      };
    };

  # x86_64-linux only packages
  flake = {
    packages =
      eachSystem
        (with inputs.flake-utils.lib.system; [
          x86_64-linux
          # aarch64-linux
        ])
        (
          {
            system,
            pkgs,
            ...
          }:
          {
            ${system} = {
              # tools
              xdg-terminal-exec = (import ./tools/xdg-terminal-exec) { inherit pkgs; };
              cider-2 = (import ./tools/cider-2) { inherit pkgs; };
            };
          }
        );

    # 다음 방법을 사용하면 packages 를 선언하는 `pkgs` 는 `allowUnfree` 가 되어야한다.
    # 다만, overlays 단에서 unfree 를 필터링함으로, 의도하지 않은 unfree 패키지가 설치될 일은 없을것으로 기대된다.
    overlays.default = _: prev: {
      my =
        if (builtins.hasAttr prev.stdenv.system self.packages) then
          (builtins.mapAttrs (_: drv: drv) (
            prev.lib.filterAttrs (
              _: derivation: (prev.config.allowUnfree || (!derivation.meta.unfree))
            ) self.packages.${prev.stdenv.system}
          ))
        else
          { };
    };
  };
}
