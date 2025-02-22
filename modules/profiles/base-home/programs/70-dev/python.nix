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
      RYE_HOME = "${config.xdg.dataHome}/rye";
    };

    python = {
      enable = true;
      pythonPackages = [
        # dev tools
        "setuptools"
        "pip"
        # "flit"

        # Lsps
        # "python-lsp-server" # lsp
        # "jedi"
        # "jedi-language-server"

        "ipython"
        "jupyter-core"
        "ipykernel"
      ];
    };

    home.packages = [
      pkgsUnstable.ruff
      pkgsUnstable.ruff-lsp
      pkgsUnstable.mypy # type-checker
      pkgsUnstable.uv # Extremely fast Python package installer and resolver
      pkgsUnstable.rye # Tool to easily manage python dependencies and environments
    ];
  };
}
