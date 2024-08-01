{...}: {
  programs.plasma.configFile."kwinrc"."Script-polonium" = {
    "Borders".value = 3;
    "KeepTiledBelow".value = false;
    "UseProcessWhitelist".value = false;
    "FilterProcessName".value = builtins.concatStringsSep ", " [
      "krunner"
      "yakuake"
      "kded"
      "polkit"
      "plasmashell"
      "systemsettings"
      "bluedevil-wizard"
      "spectacle"
      "qimgv"
      "dolphin"
      "gwenview"
      "mpv"
      "1password"
      "syncthingtray"
      "ark"
      "kdeconnect-app"
      "org.freedesktop.impl.portal.desktop.kde"
      "org.fcitx.fcitx5-qt5-gui-wrapper"
      "org.kde.kinfocenter"
      "org.kde.kmenuedit"
      "org.kde.plasma.emojier"
      "org.kde.plasma.settings.open"
      "org.kde.keditfiletype"
      "org.kde.kate"
      "org.kde.kwrite"
      "org.kde.khelpcenter"
      "org.kde.bluedevilsendfile"
      "org.kde.bluedevilwizard"
      "org.kde.kwalletmanager5"
      "com.usebottles.bottles"
      "explorer.exe"
      "kded5"
      "chromium-browser"
      "org.kde."
    ];
  };
}
