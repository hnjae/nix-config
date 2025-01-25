{ config, ... }:
let
  baseHomeCfg = config.base-home;
in
{
  programs.ssh = {
    enable = baseHomeCfg.isHome;
    # compression = true;
  };
}
