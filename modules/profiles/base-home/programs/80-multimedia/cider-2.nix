/*
  NOTE:
    - flatpak version of cider-2 does not register icon <2.6.1; 2025-03-21>
    - `cider-2.desktop` 이라는 이름으로 등록, `startupWMClass`은 `cider` 인데, 정작 실행한 인스턴스의
    클래스 이름은 `Cider` 임. `startupWMClass` 는 무시되나? <2.6.1; AppImage; Gnome 47.2>
*/
{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;

  appId = "Cider";

  backPorts = pkgsUnstable.cider-2.override {
    inherit (pkgs)
      appimageTools
      lib
      makeWrapper
      requireFile
      ;
  };

  iconFix = pkgs.runCommandLocal "${appId}-icon-fix" { } (
    let
      /*
        NOTE:
          cider 2.6.1's  "share/icons/hicolor/256x256/cider.png" icon path is not recognized by the GNOME <NixOS 24.11; Gnome 47.2>
      */
      # binary = "${backPorts}/bin/cider-2";
      icon = "${backPorts}/share/icons/hicolor/256x256/cider.png";
    in
    ''
      mkdir -p "$out/share/icons/hicolor/scalable/apps"

      cp --reflink=auto "${icon}" "$out/share/icons/hicolor/scalable/apps/${appId}.png"
    ''
  );

  desktopItemFix = pkgs.makeDesktopItem {
    desktopName = appId;
    type = "Application";
    name = appId;
    startupWMClass = appId;
    genericName = "3rd-party Apple Music Client";
    exec = "${backPorts}/bin/cider-2 %U";
    icon = appId;
    categories = [
      "Audio"
      "AudioVideo"
    ];
    mimeTypes = [
      "x-scheme-handler/ame"
      "x-scheme-handler/cider"
      "x-scheme-handler/itms"
      "x-scheme-handler/itmss"
      "x-scheme-handler/musics"
      "x-scheme-handler/music"
    ];
    actions = {
      PlayPause = {
        name = "Play-Pause";
        exec = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.cider /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause";
      };
      Next = {
        name = "Next";
        exec = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.cider /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next";
      };
      Previous = {
        name = "Previous";
        exec = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.cider /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous";
      };
      Stop = {
        name = "Stop";
        exec = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.cider /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop";
      };
    };
  };

  package = pkgs.symlinkJoin {
    name = appId;
    paths = [
      iconFix
      desktopItemFix
    ];
  };
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && baseHomeCfg.isHome && pkgs.config.allowUnfree) {
    home.packages = [ package ];

    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/sh.cider.genten";
        mode = "700";
        type = "dir";
      }
    ];
  };
}
