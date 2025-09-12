{
  config,
  pkgs,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (pkgs.hostPlatform) isLinux;
in
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
