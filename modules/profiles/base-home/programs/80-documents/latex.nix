{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = with pkgs; [
      texlivePackages.tex
    ];
    services.flatpak.packages = lib.lists.optionals (baseHomeCfg.isDesktop) [
      # "fyi.zoey.TeX-Match" # find latex symbols, uses end-of-life library (org.freedesktop.Platform 22.08) (2024-11-06)
      "io.github.finefindus.Hieroglyphic" # find latex symbols
    ];
  };
}
