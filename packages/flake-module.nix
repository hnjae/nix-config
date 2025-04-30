{
  inputs,
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
      lib,
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
        nixvim = (import ./tools/nixvim) {
          inherit (inputs) nixvim;
          inherit pkgs lib;
        };

        fonts-dmca-sans-serif = (import ./fonts/fonts-dmca-sans-serif) { inherit pkgs; };
        fonts-freesentation = (import ./fonts/fonts-freesentation) { inherit pkgs; };
        fonts-plangothic = pkgs.callPackage ./fonts/fonts-plangothic { };
        fonts-ridibatang = pkgs.callPackage ./fonts/fonts-ridibatang { };

        # unfree
        fonts-kopub-world = pkgs.callPackage ./fonts/fonts-kopub-world { };
        fonts-toss-face = (import ./fonts/fonts-toss-face) { };
      };
    };

  flake.packages =
    eachSystem
      (with inputs.flake-utils.lib.system; [
        x86_64-linux
        # aarch64-linux
      ])
      (
        {
          pkgs,
          system,
          ...
        }:
        {
          ${system} = {
            # tools
            cavif-rs = pkgs.callPackage ./tools/cavif-rs { };
            xdg-terminal-exec = pkgs.callPackage ./tools/xdg-terminal-exec { };
            qimgv-git = pkgs.kdePackages.callPackage ./tools/qimgv-git { };
          };
        }
      );
}
