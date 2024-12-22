{
  lib,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  services.flatpak.packages = lib.mkIf (genericHomeCfg.isDesktop) (let
    inherit (lib.lists) optionals;
  in
    builtins.concatLists [
      [
        "org.strawberrymusicplayer.strawberry" # NOTE: uses eol library <2024-11-15>
        "org.gnome.SoundRecorder"

        # puddletag
        "net.puddletag.puddletag"
      ]
      (optionals (genericHomeCfg.installTestApps) [
        "com.rafaelmardojai.Blanket" # white noise
        "org.kde.vvave" # music
      ])
    ]);
}
