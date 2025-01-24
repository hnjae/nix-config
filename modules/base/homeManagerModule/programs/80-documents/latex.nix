{
  pkgs,
  config,
  lib,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf baseHomeCfg.installDevPackages {
    home.packages = with pkgs; [
      texlivePackages.tex
    ];
    services.flatpak.packages =
      lib.lists.optionals (
        baseHomeCfg.isDesktop && baseHomeCfg.installTestApps
      ) [
        "io.github.finefindus.Hieroglyphic" # find latex symbols
        # "fyi.zoey.TeX-Match" # find latex symbols, uses end-of-life library (org.freedesktop.Platform 22.08) (2024-11-06)
      ];
  };
}
