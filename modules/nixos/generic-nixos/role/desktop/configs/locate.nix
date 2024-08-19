{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
in {
  services.locate = {
    enable = mkOverride 999 true;
    package = pkgs.plocate;
    interval = "monthly";
    localuser = null; # NOTE: plocate does not support localuser options <nixos 23.05>
    prunePaths = [
      "/tmp"
      "/var"
      "/nix"
      "/run"
      "/sys"
      "/raw"
    ];
  };
}