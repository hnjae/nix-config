{...}: {
  imports = [
    ./plugin-mousemark.nix
    ./plugin-diminactive.nix
  ];

  programs.plasma.configFile."kwinrc" = {
    "Effect-slide"."SlideBackground" = false;
    "Effect-overview" = {
      "OrganizedGrid" = true; # orgnaize window in grids
      "LayoutMode" = 0; # Closest (not Natural)
    };
    "Plugins" = {
      "dimscreenEnabled" = true; # dim screen for Administrator
      "shakecursorEnabled" = true; # shake cursor make cursor BIG

      # desktop switch animation
      "fadedesktopEnabled" = false;
      "slideEnabled" = true;
    };
  };
}
