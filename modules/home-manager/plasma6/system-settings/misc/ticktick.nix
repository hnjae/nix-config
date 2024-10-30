{...}: {
  plasma6.windowRules = [
    {
      uuid = "763a3e7a-8fc3-42e7-976e-a1e9fc43762c";
      description = "ticktick-rules";
      Match = {
        "wmclass".value = "ticktick";
        "wmclassmatch".value = 1; # exact match
      };
      Rule = {
        # electron CSD 앱 해당.
        # breezrc 의 windeco exception 에 추가해서 titlebar 은 숨기기
        # xwayland 로 실행하는 경우에만 사용 가능 (noborderrule = 2)
        "noborderrule".value = 2;
        # "minsize".value = "504,608";
        # "minsize".value = "580,608"; # pomodoro 가 정상적으로 렌더링되는 minsize
        "minsize".value = "836,608"; # eisenhour matrix 가 정상적으로 렌더링 되는 minsize
        "minsizerule".value = 2;
      };
    }
  ];
  programs.plasma.configFile."breezerc"."Windeco Exception 0" = {
    BorderSize = 0;
    Enabled = true;
    ExceptionPattern = "ticktick";
    ExceptionType = 0;
    HideTitleBar = true;
    Mask = 16;
  };
}
