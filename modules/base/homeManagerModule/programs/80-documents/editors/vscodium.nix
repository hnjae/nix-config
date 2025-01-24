{
  config,
  pkgsUnstable,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  # stateful vscode

  programs.vscode = {
    enable = baseHomeCfg.isDesktop && baseHomeCfg.installTestApps;
    package = pkgsUnstable.vscodium;
    # extensions = pkgsUnstable; [
    #
    # ]
  };
}
