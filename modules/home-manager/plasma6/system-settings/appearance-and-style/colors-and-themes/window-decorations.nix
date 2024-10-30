{...}: {
  programs.plasma.configFile."kwinrc"."org.kde.kdecoration2" = {
    # border size normal
    "BorderSizeAuto" = false;
    "BorderSize" = "Tiny";
  };

  programs.plasma.configFile."breezerc"."Common" = {
    ShadowSize = "ShadowSmall";
    # OutlineCloseButton = true;
  };
}
