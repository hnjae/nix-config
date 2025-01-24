{
  lib,
  config,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  services.flatpak.packages = lib.mkIf (baseHomeCfg.isDesktop) (let
    inherit (lib.lists) optionals;
  in
    builtins.concatLists [
      [
        "org.strawberrymusicplayer.strawberry" # NOTE: uses eol library <2024-11-15>
        "org.gnome.SoundRecorder"

        # puddletag
        "net.puddletag.puddletag"
      ]
      (optionals (baseHomeCfg.installTestApps) [
        "com.rafaelmardojai.Blanket" # white noise
        "org.kde.vvave" # music
      ])
    ]);
}
