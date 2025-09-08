{
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    default-app.text = "nvim";

    home.sessionVariables = {
      EDITOR = lib.mkForce "nvim";
      VISUAL = "nvim";
    };
  };
}
