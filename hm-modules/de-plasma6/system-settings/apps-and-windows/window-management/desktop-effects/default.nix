{...}: {
  imports = [./plugin-mousemark.nix];

  programs.plasma.configFile."kwinrc" = {
    "Effect-slide"."SlideBackground" = false;
    "Effect-overview"."OrganizedGrid" = false;

    "Plugins" = {
      "dimscreenEnabled" = true; # dim screen for Administrator
      # desktop switch animation
      "fadedesktopEnabled" = false;
      "slideEnabled" = false;
    };
  };
}
