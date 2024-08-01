{...}: {
  imports = [./kwin-scripts ./window-rules.nix];

  #--- Task Switcher
  programs.plasma.configFile."kwinrc"."TabBox"."LayoutName".value = "thumbnail_grid";
}
