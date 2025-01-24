{
  inputs,
  withSystem,
  ...
}: let
  eachSystem = systems: module: (inputs.nixpkgs.lib.attrsets.mergeAttrsList (
    map (system: withSystem system module) systems
  ));
in {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    packages = {
      nixvim = (import ./tools/nixvim) {
        inherit (inputs) nixvim;
        inherit pkgs;
      };
      fonts-dmca-sans-serif = pkgs.callPackage ./fonts/fonts-dmca-sans-serif {};
      fonts-plangothic = pkgs.callPackage ./fonts/fonts-plangothic {};
      fonts-ridibatang = pkgs.callPackage ./fonts/fonts-ridibatang {};
      fonts-freesentation = pkgs.callPackage ./fonts/fonts-freesentation {};

      # unfree
      fonts-kopub-world = pkgs.callPackage ./fonts/fonts-kopub-world {};
      fonts-toss-face = pkgs.callPackage ./fonts/fonts-toss-face {};
      fonts-hanazono-appending = pkgs.callPackage ./fonts/fonts-hanazono-appending {};
    };
  };

  flake.packages =
    eachSystem (with inputs.flake-utils.lib.system; [
      x86_64-linux
      # aarch64-linux
    ])
    ({
      pkgs,
      system,
      ...
    }: {
      ${system} = {
        # tools
        cavif-rs = pkgs.callPackage ./tools/cavif-rs {};
        xdg-terminal-exec = pkgs.callPackage ./tools/xdg-terminal-exec {};
        qimgv-git = pkgs.kdePackages.callPackage ./tools/qimgv-git {};
      };
    });
}
