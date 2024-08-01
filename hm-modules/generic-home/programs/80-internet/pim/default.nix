{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (lib.lists) optionals;
in {
  imports = [./thunderbird.nix];

  config = lib.mkIf (genericHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      (optionals genericHomeCfg.installTestApps [
        # email
        "com.getmailspring.Mailspring" # gpl3

        # calendar
        # "org.gnome.Calendar" # NOTE: KDE 환경에서 잘 작동 안됨.  <KDE Plasma 6.0.5>
      ])
    ];
  };
}
