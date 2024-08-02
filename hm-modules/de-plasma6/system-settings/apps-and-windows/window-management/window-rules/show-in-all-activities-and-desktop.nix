{...}: let
  inherit (builtins) concatStringsSep;
  wmclassMaker = classes: (concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
in {
  plasma6.windowRules = [
    {
      uuid = "b3d7b137-f394-4aab-a863-83e979b922f0";
      description = "show-in-all-activities-and-desktop";
      Match = {
        "wmclass".value = wmclassMaker [
          "ticktick"
          "1Password"

          # KDE's
          "systemsettings"
        ];
        "wmclassmatch".value = 3; # regex
      };
      Rule = {
        "activity".value = "00000000-0000-0000-0000-000000000000";
        "activityrule".value = 2; # force

        # virtual desktops to all desktops
        "desktops".value = "\\0";
        "desktopsrule".value = 2;

        # skip
        skippager.value = true;
        skippagerrule.value = 2;
      };
    }
  ];
}
