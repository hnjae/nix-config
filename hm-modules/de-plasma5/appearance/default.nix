{...}: {
  imports = [./window-decorations.nix ./theme.nix];

  # Appearance
  ## Fonts
  programs.plasma.configFile."kdeglobals"."General" = {
    "XftHintStyle".value = "hintfull";
    "XftSubPixel".value = "none";
    "fixed".value = "Monospace,11,-1,5,50,0,0,0,0,0";
    "font".value = "Sans Serif,11,-1,5,50,0,0,0,0,0";
    "menuFont".value = "Sans Serif,11,-1,5,50,0,0,0,0,0";
    "smallestReadableFont".value = "Sans Serif,9,-1,5,50,0,0,0,0,0";
    "toolBarFont".value = "Sans Serif,11,-1,5,50,0,0,0,0,0";
  };
  programs.plasma.configFile."kdeglobals"."WM"."activeFont".value = "Sans Serif,11,-1,5,50,0,0,0,0,0";

  ## Splash Screen
  programs.plasma.configFile."ksplashrc"."KSplash" = {
    "Theme".value = "None";
    "Engine".value = "KSplashQML";
  };
}
