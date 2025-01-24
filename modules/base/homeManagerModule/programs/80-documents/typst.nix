{
  pkgsUnstable,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
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
