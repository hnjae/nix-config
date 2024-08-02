{
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgs; [sqlite];

    services.flatpak.packages = lib.mkIf genericHomeCfg.isDesktop [
      # sql client, uses end-of-life dependency
      "com.github.alecaddd.sequeler"
    ];

    services.flatpak.overrides = lib.mkIf genericHomeCfg.isDesktop {
      "com.github.alecaddd.sequeler" = {
        Context = {shared = ["!network"];};
      };
    };
  };
}
