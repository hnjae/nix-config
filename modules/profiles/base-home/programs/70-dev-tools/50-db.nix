{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDev && baseHomeCfg.isDesktop) {
    services.flatpak.packages = lib.flatten [
      # db client
      "io.dbeaver.DBeaverCommunity" # Apache-2.0
      "io.beekeeperstudio.Studio" # GPL3
      "org.pgadmin.pgadmin4"

      # "com.github.alecaddd.sequeler" # sql client, uses end-of-life dependency
      (lib.lists.optional pkgs.config.allowUnfree "com.mongodb.Compass") # proprietary
    ];
  };
}
