{
  pkgsUnstable,
  # config,
  # lib,
  ...
}:
# let
# genericHomeCfg = config.generic-home;
# in
{
  home.packages =
    builtins.concatLists [(with pkgsUnstable; [typst typst-lsp typstfmt])];
}
