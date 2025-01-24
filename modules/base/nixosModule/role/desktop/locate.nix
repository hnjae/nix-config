{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOverride;
in
{
  services.locate = {
    enable = mkOverride 999 (config.base-nixos.role == "desktop");
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
