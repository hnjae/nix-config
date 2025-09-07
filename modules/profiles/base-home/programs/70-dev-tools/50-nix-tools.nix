{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    # locate the package providing a certain files in `nixpkgs`
    # use hm's module for shell integration
    programs.nix-index = {
      enable = true;
    };
  };
}
