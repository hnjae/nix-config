{
  config,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  xdg = {
    enable = true;
    userDirs = {
      enable = pkgs.stdenv.isLinux && baseHomeCfg.isDesktop;
      createDirectories = true;
    };
  };

  # 아래 `home.activation` 으로 해결하려 했으나 안됨 <2025-03-04>
  # systemd.user.tmpfiles.rules = [
  #   ''r "${config.xdg.configHome}/mimeapps.list.*"''
  # ];
}
