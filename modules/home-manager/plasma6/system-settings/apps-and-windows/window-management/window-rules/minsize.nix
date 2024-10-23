{...}: let
  inherit (builtins) concatStringsSep;
  wmclassMaker = classes: (concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
in {
  plasma6.windowRules = [
    {
      uuid = "1d609539-61e4-4c79-9547-1afa58776535";
      description = "minsize-big";
      Match = {
        "wmclass".value = wmclassMaker [
          "code-url-handler"
          "[cC]ode"
          "[pP]ulsar"
          "obsidian"
          "Logseq"
          "libreoffice-.*"
          "lapce"
        ];
        "wmclassmatch".value = 3;
      };
      Rule = {
        # "minsize".value = "856,534"; # 80x24 in vscode
        "minsize".value = "918,570"; # 80x24 in vscode
        # "minsize".value = "1058,534"; # 80x24 in vscode + sidebar
        "minsizerule".value = 2;
      };
    }
    {
      uuid = "a090ff76-6ffd-425e-9aa7-1b7ac776e5b1";
      description = "minsize-tiny";
      Match = {
        "wmclass".value = wmclassMaker [
          "org\\.kde\\.[(kwrite)|(partitionmanager)|(ark)]"
          "[eE]macs"
          "org\\.gnome\\.TextEditor"
          "gedit"
          "firefox"
          "librewolf"
          "google-chrome"
          "chromium-browser"
          "brave-browser"
          "[vV]ivaldi-stable"
          "Opera"
        ];
        "wmclassmatch".value = 3;
      };
      Rule = {
        "minsize".value = "532,370"; # kwrite 가 정상적으로 렌더링 되는 크기
        "minsizerule".value = 2;
      };
    }
    {
      uuid = "13800f6b-95c0-4c0e-bfdf-8ea530ea9d71";
      description = "minsize-terminal";
      Match = {
        "wmclass".value = wmclassMaker [
          "org\\.wezfurlong\\.wezterm"
          "com\\.raggesilver\\.BlackBox"
          "rio"
          "foot"
          "org.kde.konsole"
          "Alacritty"
          "termite"
          "contour"
          "kitty"
        ];
        "wmclassmatch".value = 3; # regex
      };
      Rule = {
        "minsize".value = "702,502"; # 80x24 in foot
        "minsizerule".value = 2;
      };
    }
    {
      uuid = "fec37af0-bc3b-4e16-a96b-ca999a2bf9f7";
      description = "minsize-ticktick";
      Match = {
        "wmclass".value = "ticktick";
        "wmclassmatch".value = 1;
      };
      Rule = {
        # "minsize".value = "504,608";
        # "minsize".value = "580,608"; # pomodoro 가 정상적으로 렌더링되는 minsize
        "minsize".value = "832,608"; # eisenhour matrix 가 정상적으로 렌더링 되는 minsize
        "minsizerule".value = 2;
      };
    }
    {
      uuid = "f9220e73-a8a1-4b12-8d34-691d34a0aea7";
      description = "minsize-kde-dolphin";
      Match = {
        "wmclass".value = wmclassMaker ["org.kde.dolphin"];
        "wmclassmatch".value = 3;
      };
      Rule = {
        "minsize".value = "724,500"; # 724: dolphin의 sidebar가 정상적으로 렌더링 되는 크기
        "minsizerule".value = 2;
      };
    }
  ];
}
