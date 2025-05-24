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
    };

    python = {
      enable = true;
      pythonPackages = [
        # Lsps
        # "python-lsp-server"
        # "jedi-language-server"

        "ipython"
        "mypy"
      ];
    };

    home.packages = [
      pkgsUnstable.ruff # includes lsp via `ruff server`
      pkgsUnstable.basedpyright
      pkgsUnstable.uv

      # pkgsUnstable.rye # Tool to easily manage python dependencies and environments
    ];
  };
}
