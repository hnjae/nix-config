{...}: {
  programs.plasma.configFile."bluedevilglobalrc" = {
    "Global" = {launchState = "enable";};
  };
}
