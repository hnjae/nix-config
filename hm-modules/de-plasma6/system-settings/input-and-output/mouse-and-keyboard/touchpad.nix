{lib, ...}: let
  optionTouchpadDefault = {
    "ClickMethod".value = 2;
    "NaturalScroll".value = true;
  };
  touchpads = ["Libinput/1267/12693/ELAN0676:00 04F3:3195 Touchpad"];

  inherit (builtins) listToAttrs map;
  inherit (lib.attrsets) mergeAttrsList;

  mapper = devices: opts:
    listToAttrs (map (dev: {
        name = dev;
        value = opts;
      })
      devices);
in {
  programs.plasma.configFile."kcminputrc" =
    mergeAttrsList [(mapper touchpads optionTouchpadDefault)];
}
