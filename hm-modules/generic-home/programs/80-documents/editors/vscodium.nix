{
  config,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  # stateful vscode

  programs.vscode = {
    enable = genericHomeCfg.isDesktop && genericHomeCfg.installTestApps;
    package = pkgsUnstable.vscodium;
    # extensions = pkgsUnstable; [
    #
    # ]
  };
}
