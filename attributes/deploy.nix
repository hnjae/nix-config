{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      deploy = mkSubmoduleOptions {
        nodes = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.unspecified;
          default = { };
          description = ''
            deploy-rs nodes

            <https://github.com/serokell/deploy-rs>
          '';
        };
      };
    };
  };
}
