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
    # TODO: 이걸 eval 하지 말고 패키지로 해서 source 할수 없나 <2025-02-24>
    # programs.zsh.initExtra = ''
    #   eval "$(rye self completion -s zsh)"
    # '';

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

      # pkgsUnstable.uv # Extremely fast Python package installer and resolver
      pkgsUnstable.rye # Tool to easily manage python dependencies and environments
    ];
  };
}
