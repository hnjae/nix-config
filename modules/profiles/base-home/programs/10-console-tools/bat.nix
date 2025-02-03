{
  config,
  lib,
  ...
}:
let
  base24Cfg = config.base-home.base24;
in
{
  programs.bat = {
    enable = true;
  };

  home.sessionVariables = {
    # NOTE: can not override nixos's environment.variables or kde locale settings here

    # NOTE: BAT_THEME의 ansi 는 comment 로 회색을 사용하지 않는다.
    BAT_THEME = lib.mkDefault (
      if (!base24Cfg.enable) then
        "ansi"
      else if (base24Cfg.scheme == "gruvbox") then
        "gruvbox-${if base24Cfg.variant == "light" then "light" else "dark"}"
      else
        "base16"
    );
    /*
      -F: --quit-if-one-screen
      -L: --no-lessopen
      -R: --RAW-CONTROL-CHARS
    */
    BAT_PAGER = "less -iLR";
    # `snip`: 여러개의 line-range 있을 때 구분선 그음.
    BAT_STYLE = "snip,changes,grid,numbers";
  };

  home.shellAliases = {
    # bat = "bat --paging=never";
    c = "bat --paging=never --style=plane";
  };
}
