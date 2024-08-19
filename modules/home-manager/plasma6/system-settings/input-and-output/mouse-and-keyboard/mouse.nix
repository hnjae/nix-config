{lib, ...}: let
  optionMouseDefault = {
    "NaturalScroll".value = true;
    "PointerAccelerationProfile".value = 2; # pointer acceleration
  };
  mouses = [
    "Libinput/9639/64124/Compx X2 Mini Wireless"
    "Libinput/1133/50504/Logitech USB Receiver Mouse"
  ];

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
    (mapper mouses optionMouseDefault)
    (mapper [
        # NOTE: trackpad's TrackPoint
        "Libinput/2/10/TPPS\\/2 Elan TrackPoint"
      ] (optionMouseDefault
        // {
          "NaturalScroll".value = false;
          "PointerAccelerationProfile".value = 1; # no pointer acceleration
        }))
    (mapper [
        # Trackballs
        "Libinput/1149/32934/Kensington ORBIT WIRELESS TB Mouse"
      ] (optionMouseDefault
        // {
          "LeftHanded" = true;
          "NaturalScroll".value = true;
          "PointerAccelerationProfile".value = 2;
          "PointerAcceleration" = "-0.500";
        }))
    (mapper ["Libinput/6127/24815/Lenovo Bluetooth Mouse"] (optionMouseDefault
      // {
        "PointerAcceleration" = "-0.800";
        "LeftHanded" = true;
      }))
  ];
}
