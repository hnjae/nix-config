{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      # bash
      checkbashisms
      shellharden
      shfmt
      beautysh
      shellcheck

      # shellcheck deprecated over bashls in none-ls
      nodePackages.bash-language-server
    ];
  };
}
