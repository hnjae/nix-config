{...}: let
  inherit (builtins) concatStringsSep;
  wmclassMaker = classes: (concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
in {
  plasma6.windowRules = [
    {
      uuid = "4e4c078d-50ad-4eba-822f-987a75246b5e";
      description = "force border to various applications";
      Match = {
        "wmclass".value = wmclassMaker ["ticktick"];
        "wmclassmatch".value = 3;
      };
      Rule = {
        # electron CSD 앱 해당.
        # breezrc 의 windeco exception 에 추가해서 titlebar 은 숨기기
        # xwayland 로 실행하는 경우에만 사용 가능 (noborderrule = 2)
        "noborderrule".value = 2;
      };
    }
  ];
}
