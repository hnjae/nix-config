{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    home.sessionVariables = {
      PYTHON_HISTORY = "${config.xdg.stateHome}/python_history"; # from python 3.13
      PYTHON_COLORS = 1;
      IPYTHONDIR = "${config.xdg.stateHome}/ipython";

      # a local cache of the registry index and of git checkouts of crates
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
    };
    home.file.".npmrc" = {
      enable = true;
      text = ''
        cache="${config.xdg.stateHome}/npm"
      '';
    };
  };
}
