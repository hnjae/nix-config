{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = [ pkgs.rust-bin.stable.latest.default ];

    home.sessionVariables = {
      # a local cache of the registry index and of git checkouts of crates
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
    };
  };
}
