let
  project = "autoaspm";
in
{
  flake-parts-lib,
  self,
  ...
}:
let

  inherit (flake-parts-lib) importApply;
  flakeArgs = {
    localFlake = self;
    inherit project;
  };
in
{
  flake.nixosModules."${project}" = importApply ./module.nix flakeArgs;

  perSystem =
    {
      pkgs,
      lib,
      config,
      system,
      ...
    }:
    let
      isSupported = builtins.elem system [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      packages = lib.mkIf isSupported {
        ${project} = pkgs.callPackage ./derivation.nix { };
      };

      apps = lib.mkIf isSupported {
        ${project} = {
          type = "app";
          program = config.packages."${project}";
        };
      };

      devShells.${project} = import ./shell.nix { inherit pkgs; };
    };
}
