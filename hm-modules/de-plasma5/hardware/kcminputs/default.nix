# NOTE: PointerAccelerationProfile -  1: flat, 2: adaptive <2024-01-29>
{lib, ...}: let
  optTouchpad = {
    "NaturalScroll".value = true;
    "TapToClick".value = true;
    "PointerAccelerationProfile".value = 2; # adaptive
    "ClickMethod".value = 2; # two finger to right click
  };
  optMouse = {
    "NaturalScroll".value = true;
    "PointerAccelerationProfile".value = 1;
  };
  optTrackpoint = {
    "NaturalScroll".value = true;
    "PointerAccelerationProfile".value = 2;
  };

  touchpads = ["Libinput.1267.12693.ELAN0676:00 04F3:3195 Touchpad"];
  mouses = [
    "Libinput.1133.45089.Logi Pebble Mouse"
    "Libinput.6127.24815.Lenovo Bluetooth Mouse"
  ];
  trackpoints = ["Libinput.2.10.TPPS/2 Elan TrackPoint"];

  inherit (builtins) listToAttrs map;
  inherit (lib.attrsets) mergeAttrsList;

  mapper = devices: opts:
    listToAttrs (map (dev: {
        name = dev;
        value = opts;
      })
      devices);
in {
  programs.plasma.configFile."kcminputrc" = mergeAttrsList [
    (mapper trackpoints optTrackpoint)
    (mapper mouses optMouse)
    (mapper touchpads optTouchpad)
  ];
}
