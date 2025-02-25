{ inputs, ... }:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{

  home.packages = builtins.concatLists [
    (lib.lists.optional (
      (inputs.py-utils ? packages && baseHomeCfg.isHome)
    ) inputs.py-utils.packages.${pkgs.stdenv.system}.default)
  ];
}
