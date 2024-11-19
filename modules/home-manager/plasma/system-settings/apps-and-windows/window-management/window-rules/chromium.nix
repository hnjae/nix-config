{...}: let
  Rule = {
    # below all other windows
    "below".value = true;
    "belowrule".value = 2; # force

    skippager.value = true;
    skippagerrule.value = 2;

    skipswitcher.value = true;
    skipswitcherrule.value = 2;
  };
in {
  plasma6.windowRules = [
    {
      uuid = "d2472abd-c8d3-400e-a998-fa235acb7fb3";
      description = "chromium";
      Match = {
        "wmclass".value = "Chromium-browser";
        "wmclassmatch".value = 1; # exact match
      };
      inherit Rule;
    }
  ];
}
