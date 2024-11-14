{...}: let
  Rule = {
    # above all other windows
    "above".value = true;
    "aboverule".value = 2; # force
    # virtual desktops to all desktops
    "desktops".value = "\\0";
    "desktopsrule".value = 2;
    #
    "minimizerule".value = 2; # force not to minimize
    "noborderrule".value = 2; # force titlebar and frame
    # Show in all workspaces
    "activity".value = "00000000-0000-0000-0000-000000000000";
    "activityrule".value = 2; # force
  };
in {
  plasma6.windowRules = [
    {
      uuid = "2c0a51a9-6f20-4e0f-8c02-c14163f16956";
      description = "prompt of KDE polkit";
      Match = {
        "wmclass".value = "org.kde.polkit-kde-authentication-agent-1";
        "wmclassmatch".value = 2; # substring match
        "title".value = "Authentication Required";
        "titlematch".value = 2; # substring match
      };
      inherit Rule;
    }
    {
      uuid = "79768645-32fe-4931-a4ed-f8ce40c9ebb9";
      description = "prompt of 1password";
      Match = {
        "wmclass".value = "1password";
        "wmclassmatch".value = 1; # exact match
        "title".value = "1Password";
        "titlematch".value = 1; # exact match
      };
      Rule =
        Rule
        // {
          # xwayland 로 실행하는 경우에만 사용 가능 (noborderrule = 2)
          "noborderrule".value = 2;
          # initial placement - center
          placementrule = 2;
        };
    }
  ];
}
