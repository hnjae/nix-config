{
  config,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  # stateful vscode

  programs.vscode = {
    enable = baseHomeCfg.isDesktop;
    package = pkgsUnstable.vscodium;
    mutableExtensionsDir = false;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    extensions = with pkgsUnstable.vscode-extensions; [
      asvetliakov.vscode-neovim

      ms-pyright.pyright
      ms-python.mypy-type-checker
      charliermarsh.ruff
    ];
  };
}
