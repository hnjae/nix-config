{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;
  home-manager.extraSpecialArgs = lib.mkOverride 100 {
    pkgsUnstable = import inputs.nixpkgs-unstable {
      system = inputs.flake-utils.lib.system.x86_64-linux;
      config.allowUnfree = true;
    };
    isNvidia = false;
  };
}
