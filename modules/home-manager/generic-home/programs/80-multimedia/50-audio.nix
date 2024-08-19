{
  lib,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  services.flatpak.packages = let
    inherit (lib.lists) optionals;
  in
    builtins.concatLists [
      (optionals genericHomeCfg.isDesktop
        ["org.strawberrymusicplayer.strawberry"])
      (optionals (genericHomeCfg.isDesktop && genericHomeCfg.installTestApps) [
        "com.rafaelmardojai.Blanket" # white noise
        "org.kde.vvave" # music
      ])
    ];
}
