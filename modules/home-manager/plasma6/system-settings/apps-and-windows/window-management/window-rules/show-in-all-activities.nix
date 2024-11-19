{...}: let
  inherit (builtins) concatStringsSep;
  wmclassMaker = classes: (concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
in {
  plasma6.windowRules = [
    {
      uuid = "dfd83485-e35f-499a-9068-8b43577df6c5";
      description = "show-in-all-activities";
      Match = {
        "wmclass".value = wmclassMaker [
          # 여러 윈도우 여는걸 허락하지 않는 애플리케이션

          # KDE's
          "org.kde.polkit-kde-authentication-agent-1"
        ];
        "wmclassmatch".value = 3; # regex
      };
      Rule = {
        "activity".value = "00000000-0000-0000-0000-000000000000";
        "activityrule".value = 2; # force
      };
    }
    {
      uuid = "2d0fa865-3761-483f-9892-123e20dcd87c";
      description = "syncthingtray";
      Match = {
        "wmclass".value = "syncthingtray";
        "wmclassmatch".value = 2; # substring match
      };
      Rule = {
        "activity".value = "00000000-0000-0000-0000-000000000000";
        "activityrule".value = 2; # force
        "above".value = true;
        "aboverule".value = 2; # force
      };
    }
  ];
}
