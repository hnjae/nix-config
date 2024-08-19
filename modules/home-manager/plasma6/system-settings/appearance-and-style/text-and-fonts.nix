{...}: let
  defaultFontType = {
    family = "Sans Serif";
    pointSize = 10;
  };
in {
  # programs.plasma.configFile."kdeglobals"."General" = {
  #   "XftHintStyle".value = "hintfull";
  #   "XftSubPixel".value = "none";
  #   "fixed".value = "Monospace,11,-1,5,50,0,0,0,0,0";
  #   "font".value = "Sans Serif,11,-1,5,50,0,0,0,0,0";
  #   "menuFont".value = "Sans Serif,11,-1,5,50,0,0,0,0,0";
  #   "smallestReadableFont".value = "Sans Serif,9,-1,5,50,0,0,0,0,0";
  #   "toolBarFont".value = "Sans Serif,11,-1,5,50,0,0,0,0,0";
  # };
  programs.plasma.fonts = {
    general = defaultFontType;
    toolbar = defaultFontType;
    menu = defaultFontType;
    windowTitle = defaultFontType;
    fixedWidth = defaultFontType // {family = "Monospace";};
    small = defaultFontType // {pointSize = 8;};
  };
}
