{...}: let
  inherit (builtins) attrNames length concatStringsSep;
  wmclassMaker = classes: (concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
  rules = {
    "6af740c7-7100-4495-9576-c7ee77e44672" = {
      "Description".value = "minsize";
      "minsize".value = "560,416";
      "minsizerule".value = 2;
      "wmclass".value = wmclassMaker [
        "firefox"
        "org.gnome.TextEditor"
        "org.kde.[(kwrite)|(partitionmanager)|(dolphin)]"
        "org.mozilla.Thunderbird"
        "code-url-handler"
        "code"
        "google-chrome"
        "chromium-browser"
        "vivaldi-stable"
        "brave-browser"
        "obsidian"
        "libreoffice-.*"
        "lapce"
      ];
      "wmclassmatch".value = 3;
    };
    "0be5a1c4-2dfe-44bb-b81a-255e4ac66cec" = {
      "Description".value = "force-border";
      # electron CSD 앱 해당.
      # breezrc 의 windeco exception 에 추가해서 titlebar 은 숨기기
      # xwayland 로 실행하는 경우에만 사용 가능 (noborderrule = 2)
      "noborderrule".value = 2;
      "wmclass".value = wmclassMaker [
        "ticktick"
        # "logseq"
      ];
      "wmclassmatch".value = 3;
    };
    "93ae59ec-2abb-4463-a8b1-5747abc641e3" = {
      "Description".value = "ticktick-minsize";
      # "minsize".value = "504,608";
      # "minsize".value = "580,608"; # pomodoro 가 정상적으로 렌더링되는 minsize
      "minsize".value = "832,608"; # eisenhour matrix 가 정상적으로 렌더링 되는 minsize
      "minsizerule".value = 2;
      "wmclass".value = "ticktick";
      "wmclassmatch".value = 1;
    };
    "b311b641-c76f-4317-9b11-3248a4261c36" = {
      "Description".value = "logseq-minsize";
      # 상단바 아이콘들이 안겹치는 크기, 각종 플러그인 아이콘 때문에 커질수
      # 밖에 없음.
      # "minsize" = "804,412";
      "minsize".value = "648,412"; # native titlebar 사용할때
      "minsizerule".value = 2;
      "wmclass".value = "logseq";
      "wmclassmatch".value = 1;
    };
    "2c8ae1ae-fbd6-4e1b-9483-d91ae23a3972" = {
      "Description".value = "terminal-minsize";
      # "minsize" = "804,528";
      "minsize".value = "400,264";
      "minsizerule".value = 2;
      #
      "wmclass".value = wmclassMaker [
        "org.wezfurlong.wezterm"
        "com.raggesilver.BlackBox"
        "rio"
        "foot"
        "org.kde.konsole"
        "Alacritty"
        "termite"
        "contour"
      ];
      "wmclassmatch".value = 3; # regex
    };
    "8430ccc2-3954-4f04-9b87-b52ca5392cb9" = {
      "Description".value = "1password-prompt";
      "wmclass".value = wmclassMaker ["1password"];
      "wmclassmatch".value = 3; # exact match
      #
      "title".value = "1Password";
      "titlematch".value = 1; # exact match
      # above all other windows
      "above".value = true;
      "aboverule".value = 2; # force
      # virtual desktops to all desktops
      "desktops".value = "\\\\0";
      "desktopsrule".value = 2;
      #
      "noborderrule".value = 2; # force titlebar and frame
      "minimizerule" = 2; # force not to minimize
    };
    "8ab1912e-b8dc-4f2d-bc7b-cc10b4e73a81" = {
      "Description".value = "polkit-prompt";
      "wmclass".value =
        wmclassMaker ["org.kde.polkit-kde-authentication-agent-1"];
      "wmclassmatch".value = 3; # exact match
      "title".value = "Authentication Required";
      "titlematch".value = 2; # substring match
      # above all other windows
      "above".value = true;
      "aboverule".value = 2; # force
      # virtual desktops to all desktops
      "desktops".value = "\\\\0";
      "desktopsrule".value = 2;
      "minimizerule" = 2; # force not to minimize
    };
  };
in {
  programs.plasma.configFile."kwinrulesrc" =
    rules
    // {
      "General" = {
        "count".value = length (attrNames rules);
        "rules".value = concatStringsSep "," (attrNames rules);
      };
    };
}
