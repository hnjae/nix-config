{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.shellAliases = {
      python = "ipython3";
      python3 = "ipython3";
    };

    home.sessionVariables = {
      PYTHON_HISTORY = "${config.xdg.stateHome}/python_history"; # from python 3.13
      PYTHON_COLORS = 1;
    };

    python = {
      enable = true;
      pythonPackages = [
        # dev tools
        "setuptools"
        "flit"
        "pip"

        "ruff-lsp" # linter
        "python-lsp-server" # lsp
        "mypy" # typechecker

        # formatters
        # "isort"
        # "black"

        #
        # "pydocstyle"

        # Lsps
        # "jedi"
        # "jedi-language-server"

        "ipython"
        "jupyter-core"
        "ipykernel"
      ];
    };

    home.packages = [
      pkgsUnstable.ruff
      pkgsUnstable.poetry
      # pkgs.pylyzer
      # pkgsUnstable.nodePackages.pyright
      # pkgsUnstable.pipx
      # pkgsUnstable.pipenv
    ];
  };
}
