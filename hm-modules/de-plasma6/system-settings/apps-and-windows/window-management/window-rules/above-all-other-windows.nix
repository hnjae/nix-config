{...}: let
  Rule = {
    # above all other windows
    "above".value = true;
    "aboverule".value = 2; # force
    #
    "minimizerule".value = 2; # force not to minimize
  };
in {
  plasma6.windowRules = [
    {
      uuid = "aec36a41-6704-4c77-bcbe-4b52852d580a";
      description = "portal-window";
      Match = {
        "wmclass".value = "org.freedesktop.impl.portal.desktop.kde";
        "wmclassmatch".value = 1; # exact match
      };
      inherit Rule;
    }
  ];
}
