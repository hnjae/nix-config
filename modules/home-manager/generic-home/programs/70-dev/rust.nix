{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
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
