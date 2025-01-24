{
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  services.flatpak.packages = lib.mkIf (baseHomeCfg.isDesktop) (
    builtins.concatLists [
      [
        "org.strawberrymusicplayer.strawberry" # NOTE: uses eol library <2024-11-15>
        "org.gnome.SoundRecorder"

        # puddletag
        "net.puddletag.puddletag"
        "com.rafaelmardojai.Blanket" # white noise
      ]
    ]
  );
}
