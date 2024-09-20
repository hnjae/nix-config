{...}: {
  # Spectacle
  programs.plasma.shortcuts."services/org.kde.spectacle.desktop" = {
    # default: ["Print" "Meta+Shift+S"];
    # Colemak 자판 + Meta/Alt 스왑 대응 추가
    "_launch" = ["Alt+Shift+R" "Print" "Meta+Shift+S"];

    # default: Meta+Print
    "ActiveWindowScreenShot" = ["Alt+Print"];

    "RecordRegion" = ["Meta+Shift+R"]; # defaults: ["Meta+R", "Meta+Shift+R"]

    # defaultS: ["Meta+Alt+R"]
    "RecordScreen" = ["Ctrl+Alt+Shift+R" "Meta+Alt+R"];
  };

  # Emoji Selector
  programs.plasma.shortcuts."services/org.kde.plasma.emojier.desktop"."_launch" = [
    "Meta+Ctrl+Alt+Shift+Space"

    # fcitx 의 quickpharase 기능 쓸 것.
    # "Meta+."
    # "Alt+." # Meta/Alt 스왑 대응
  ];

  # Krunner
  programs.plasma.shortcuts."services/org.kde.krunner.desktop"."_launch" = ["Alt+F2" "Alt+Space" "Search" "Meta+Space"];
}
