{ localFlake, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.base-nixos;
in
{
  programs.nano.enable = false;

  environment.systemPackages = lib.flatten [
    (localFlake.packageSets.system pkgs)
    [
      config.boot.kernelPackages.cpupower
      config.boot.kernelPackages.x86_energy_perf_policy
    ]
  ];

  users.users.hnjae.packages = lib.flatten [
    (lib.lists.optionals (cfg.role == "desktop") (
      builtins.concatLists [
        (localFlake.packageSets.dev pkgs)
        (localFlake.packageSets.desktop pkgs)
      ]
    ))

    (localFlake.packageSets.user pkgs)
    (localFlake.packageSets.home pkgs)
  ];
}
