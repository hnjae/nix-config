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
      inputs.py-utils ? packages && baseHomeCfg.isHome
    ) inputs.py-utils.packages.${pkgs.system}.default)
    (lib.lists.optionals baseHomeCfg.isDev [
      inputs.yaml2nix.packages.${pkgs.system}.default
    ])
  ];
}
