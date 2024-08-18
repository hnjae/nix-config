{
  pkgsUnstable,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = builtins.concatLists [
      (with pkgsUnstable; [
        typst
        typst-lsp
        typstfmt
      ])
    ];
  };
}
