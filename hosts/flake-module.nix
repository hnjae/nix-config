{ self, inputs, ... }:
{
  imports = [
    ./eris/flake-module.nix
    ./isis/flake-module.nix
    ./osiris/flake-module.nix

    ./iso/flake-module.nix
  ];

  flake.checks = builtins.mapAttrs (
    _: deployLib: deployLib.deployChecks self.deploy
  ) inputs.deploy-rs.lib;
}
