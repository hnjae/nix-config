_: {
  programs.plasma.configFile."kwinrc" = {
    "Effect-diminactive" = {
      DimByGroup = false;
      Strength = 4;
    };

    "Plugins".diminactiveEnabled = true;
  };
}
