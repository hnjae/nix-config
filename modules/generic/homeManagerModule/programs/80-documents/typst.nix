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
        tinymist
        # typst-lsp # deprecated 2024-11-05
        typstfmt
      ])
    ];
  };
}
