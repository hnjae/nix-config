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
      nixvim = (import ./tools/nixvim) inputs.nixvim pkgs;
      vim-declared = (import ./tools/vim-declared) pkgs;
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
      aarch64-linux
    ])
    ({
      pkgs,
      system,
      ...
    }: {
      ${system} = {
        # tools
        cavif-rs = pkgs.callPackage ./tools/cavif-rs {};
        lf-sixel = pkgs.callPackage ./tools/lf-sixel {};
        xdg-terminal-exec = pkgs.callPackage ./tools/xdg-terminal-exec {};
        qimgv-git = pkgs.kdePackages.callPackage ./tools/qimgv-git {};

        # Plasma 6
        compact-pager = pkgs.callPackage ./kde/compact-pager {};
        application-title-bar = pkgs.callPackage ./kde/application-title-bar {};

        # Plasma 5
        plasma-applet-active-window-control =
          pkgs.libsForQt5.callPackage
          ./kde/plasma-applet-active-window-control
          {};
        kwin-script-always-open-on =
          pkgs.libsForQt5.callPackage
          ./kde/kwin-script-always-open-on {};
        # koi =
        #   pkgs.libsForQt5.callPackage ./kde/koi {};

        # SDDM
        sddm-theme-slice = pkgs.callPackage ./themes/sddm-theme-slice {};
        sddm-theme-corners = pkgs.callPackage ./themes/sddm-theme-corners {};
        sddm-theme-sugar-dark = pkgs.callPackage ./themes/sddm-theme-sugar-dark {};

        # Wallpapers
        wallpapers-whitesur = pkgs.callPackage ./themes/wallpapers-whitesur {};

        # Plasma 5 Theme (아마도 Plasma6 랑 호환될듯?)
        kde-theme-whitesur = pkgs.callPackage ./themes/kde-theme-whitesur {};
        kde-theme-fluent = pkgs.callPackage ./themes/kde-theme-fluent {};
        kde-theme-monterey = pkgs.callPackage ./themes/kde-theme-monterey {};
        kde-theme-we10xos = pkgs.callPackage ./themes/kde-theme-we10xos {};
      };
    });
}
