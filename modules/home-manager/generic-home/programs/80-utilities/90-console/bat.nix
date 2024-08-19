{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  programs.bat = {enable = true;};

  home.sessionVariables = {
    # NOTE: can not override nixos's environment.variables or kde locale settings here
    BAT_THEME =
      lib.mkDefault
      (
        if (genericHomeCfg.base24.enable)
        then "base16"
        else "ansi"
      );
    # -F: --quit-if-one-screen, -L: --no-lessopen, -R: --RAW-CONTROL-CHARS
    BAT_PAGER = "less -iFLR";
    # `snip`: 여러개의 line-range 있을 때 구분선 그음.
    BAT_STYLE = "snip,changes,grid";
  };

  home.shellAliases = {c = "bat";};
}
