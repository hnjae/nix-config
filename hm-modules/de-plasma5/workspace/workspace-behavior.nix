{config, ...}: let
  # Present-windows
  # 0: closest
  # 1: natural (?)
  presentWindowLayoutMode = 1;
in {
  #--- General Behavior
  # disable single-click open
  programs.plasma.workspace.clickItemTo = "select";

  #--- Desktop Effects
  programs.plasma.configFile."kwinrc"."Effect-desktopgrid"."DesktopLayoutMode".value =
    1; # desktop grid to auto
  programs.plasma.configFile."kwinrc"."Effect-desktopgrid"."LayoutMode".value =
    presentWindowLayoutMode;

  programs.plasma.configFile."kwinrc"."Effect-windowview"."IgnoreMinimized".value =
    true;

  programs.plasma.configFile."kwinrc"."Effect-windowview"."LayoutMode".value =
    presentWindowLayoutMode;

  programs.plasma.configFile."kwinrc"."Effect-overview"."IgnoreMinimized".value =
    presentWindowLayoutMode;
  programs.plasma.configFile."kwinrc"."Effect-overview"."LayoutMode".value =
    presentWindowLayoutMode;
  programs.plasma.configFile."kwinrc"."Effect-overview"."BlurBackground".value =
    true;

  programs.plasma.configFile."kwinrc"."Plugins"."kwin4_effect_loginEnabled".value =
    false;
  programs.plasma.configFile."kwinrc"."Plugins"."kwin4_effect_logoutEnabled".value =
    false;

  programs.plasma.configFile."kwinrc"."Plugins"."mousemarkEnabled".value =
    false;

  # effect while changing desktop (touchpad로 스위칭 할 경우 키는게 좋다.)
  programs.plasma.configFile."kwinrc"."Plugins"."slideEnabled".value = false;

  #--- recent-files
  programs.plasma.configFile."kactivitymanagerd-pluginsrc" = {
    "Plugin-org\\.kde\\.ActivityManager\\.Resources\\.Scoring" = {
      keep-history-for.value = 1; # 1 month
    };
  };

  #--- Screen Locking
  programs.plasma.configFile."kscreenlockerrc" = {
    # "Greeter"."WallpaperPlugin" = "org.kde.hunyango";
    # "Greeter"."WallpaperPlugin".value = "org.kde.potd";
    # "Greeter.Wallpaper.org.kde.potd.General"."Provider".value = "natgeo";

    "Greeter"."WallpaperPlugin".value = "org.kde.color";
    "Greeter.Wallpaper.org.kde.color.General"."Color".value = "32,32,28";
  };
}
