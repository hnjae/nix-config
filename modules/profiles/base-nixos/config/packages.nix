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
        (localFlake.packageSets.user-desktop-nixos pkgs)

        (localFlake.packageSets.user-dev pkgs)
        (localFlake.packageSets.user-dev-desktop-nixos pkgs)
      ]
    ))

    (localFlake.packageSets.user pkgs)
    (localFlake.packageSets.user-home pkgs)
  ];

  programs.adb.enable = cfg.role == "desktop";

  # Run unpatched dynamic binaries
  programs.nix-ld = {
    enable = cfg.role == "desktop";
    libraries = with pkgs; [
      # marksman requires
      icu
      vulkan-loader
    ];
  };

  home-manager.sharedModules = lib.flatten [
    (lib.lists.optional (cfg.role == "desktop") localFlake.homeManagerModules.mpv)
    localFlake.homeManagerModules.pistol
  ];
}
