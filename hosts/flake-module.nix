{ self, inputs, ... }:
{
  imports = [
    ./horus/flake-module.nix
    ./isis/flake-module.nix
    ./nixos-iso/flake-module.nix
    ./osiris/flake-module.nix
  ];

  flake.checks = builtins.mapAttrs (
    _: deployLib: deployLib.deployChecks self.deploy
  ) inputs.deploy-rs.lib;
}
