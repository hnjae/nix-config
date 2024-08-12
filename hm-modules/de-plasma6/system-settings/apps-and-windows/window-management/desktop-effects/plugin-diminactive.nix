_: {
  programs.plasma.configFile."kwinrc" = {
    "Effect-diminactive" = {
      DimByGroup = false;
      Strength = 8;
    };

    "Plugins".diminactiveEnabled = true;
  };
}
