{
  config,
  lib,
  pkgs,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf baseHomeCfg.installDevPackages {
    # home.packages = [pkgs.rust-bin.stable.latest.default];

    home.sessionVariables = {
      # a local cache of the registry index and of git checkouts of crates
      CARGO_HOME = "${config.xdg.stateHome}/cargo";
    };

    stateful.nodes = [
      {
        path = "${config.xdg.stateHome}/cargo";
        mode = "755";
        type = "dir";
      }
    ];
  };
}
