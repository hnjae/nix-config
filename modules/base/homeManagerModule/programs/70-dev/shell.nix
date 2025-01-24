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
    home.packages = with pkgsUnstable; [
      # bash
      checkbashisms
      shellharden
      shfmt
      beautysh
      shellcheck

      # shellcheck deprecated over bashls in none-ls
      bash-language-server
    ];
  };
}
