{
  config,
  lib,
  ...
}: let
  baseHomeCfg = config.base-home;
  inherit (lib.lists) optionals;
in {
  imports = [./thunderbird.nix];

  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      (optionals baseHomeCfg.installTestApps [
        # email
        "com.getmailspring.Mailspring" # gpl3

        # calendar
        # "org.gnome.Calendar" # NOTE: KDE 환경에서 잘 작동 안됨.  <KDE Plasma 6.0.5>
        # "org.kde.kontact"
      ])
    ];
  };
}
