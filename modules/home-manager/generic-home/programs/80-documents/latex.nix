{
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgs; [
      texlivePackages.tex
    ];
    services.flatpak.packages =
      lib.lists.optionals (
        genericHomeCfg.isDesktop && genericHomeCfg.installTestApps
      ) [
        "io.github.finefindus.Hieroglyphic" # find latex symbols
        # "fyi.zoey.TeX-Match" # find latex symbols, uses end-of-life library (org.freedesktop.Platform 22.08) (2024-11-06)
      ];
  };
}
