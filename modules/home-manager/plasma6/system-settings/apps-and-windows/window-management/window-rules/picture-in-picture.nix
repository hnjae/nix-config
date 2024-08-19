{...}: let
  wmclassMaker = classes: (builtins.concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
  Rule = {
    "above".value = true;
    "aboverule".value = 2;
    "noborderrule".value = 2;
    "skipswitcher".value = true;
    "skipswitcherrule".value = 2;
    "skiptaskbar".value = true;
    "skiptaskbarrule".value = 2;
  };
in {
  plasma6.windowRules = [
    {
      uuid = "4de9c291-c037-46d1-af24-d53838a44fed";
      description = "Picture-in-Picture window of various browser";
      Match = {
        "title".value = "Picture in picture";
        "titlematch".value = 1;
        "wmclass".value = wmclassMaker [
          "microsoft-edge"
          "[vV]ivaldi-stable"
          "brave-browser"
          "google-chrome"
          "chromium-browser"
          "Opera"
        ];
        "wmclassmatch".value = 3;
        # "wmclasscomplete".value = true;
      };
      inherit Rule;
    }
    {
      uuid = "386ee3e3-3124-4d26-9e27-3486a8a217de";
      description = "Picture-in-Picture of Firefox";
      Match = {
        "title".value = "Picture-in-Picture";
        "titlematch".value = 1;
        "types".value = 1;
        "wmclass".value = "firefox";
        "wmclasscomplete".value = true;
        "wmclassmatch".value = 2;
      };
      inherit Rule;
    }
  ];
}
