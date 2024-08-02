{
  dirs = {
    "755" = [
      # ".local/share/color-schemes" # statefull 하게 사용 안함.
      ".local/share/kwin"
      ".local/share/kdevappwizard"
      ".local/share/kdevelop"
      ".local/share/kdevscratchpad"
      # ".local/share/kxmlgui5"
      # ".local/share/plasma"
      ".local/share/knewstuff3"
      ".local/share/kwalletd"
      ".local/share/khelpcenter"
      ".local/share/systemsettings"
      # ".local/share/plasma-interactiveconsole"
      ".config/xsettingsd"
      ".config/KDE"
      ".config/kdeconnect"
      ".config/kdedefaults"
      ".config/kde.org"
      ".config/gtk-3.0"
      ".config/gtk-4.0"
      ".config/session"
      ".config/plasma-workspace"
      ".local/share/kded6"
      ".local/share/plasmashell"
    ];
    "700" = [".config/dconf"];
  };
  files = {
    "600" = [
      # ".config/ksmserverrc" # 덮어쓰기됨
      # ".config/kwalletrc" # 덮어쓰기됨
      # ".config/kxkbrc" # 덮어쓰기 됨
      # ".config/mimeapps.list" # 덮어쓰기됨
      # ".config/systemsettingsrc"
      # ".config/plasmashellrc" # 덮어쓰기 됨.
      # ".config/kded5rc"
      # ".config/kded6rc"
      ".config/kwriterc"
      ".config/arkrc"
      ".config/plasmarc"
      ".config/kdeveloprc"
      ".config/plasma.emojierrc"
      ".config/baloofileinformationrc"
      ".config/kfontinstuirc"
      ".config/kmenueditrc"
      ".config/kdeglobals"
      ".config/powerdevilrc"
      ".config/systemmonitorrc"
      ".config/startkderc"
      ".config/spectaclerc"
      ".config/powermanagementprofilesrc"
      ".config/plasma_workspace.notifyrc"
      ".config/plasmarc"
      # ".config/plasma-org.kde.plasma.desktop-appletsrc" # plasma-manager의 panel 모듈에서 직접 관리
      ".config/plasmanotifyrc"
      ".config/plasma-localerc"
      ".config/lightlyrc"
      ".config/kwinrulesrc"
      ".config/kwinrc"
      ".config/kwalletmanager5rc"
      ".config/ktimezonedrc"
      ".config/kscreenlockerrc"
      ".config/kmixrc"
      ".config/kinfocenterrc"
      ".config/khotkeysrc"
      ".config/kglobalshortcutsrc"
      ".config/kconf_updaterc"
      ".config/kcminputrc"
      ".config/gwenviewrc"
      ".config/filetypesrc"
      ".config/bluedevilglobalrc"
      ".config/baloofilerc"
      ".config/xdg-desktop-portal-kderc"
      ".config/plasma-interactiveconsolerc"
      ".config/partitionmanagerrc"
      ".config/khelpcenterrc"
      ".config/kfontviewrc"
      ".config/plasma-systemmonitorrc"
      ".config/plasmawindowed-appletsrc"
      ".config/plasmawindowedrc"
      ".config/device_automounter_kcmrc"
      ".config/drkonqirc"
    ];
    "644" = [
      # 아래 파일들은 덮어쓰기 되어 symbolic link 유지가 안됨
      # ".gtkrc-2.0"
      ".config/Trolltech.conf"

      ".config/breezerc"
      ".config/gtkrc"
      ".config/gtkrc-2.0"
      ".config/ksplashrc"
      ".config/plasmaparc"
      ".config/QtProject.conf"
      ".config/user-dirs.locale"
      ".config/kwinoutputconfig.json"
    ];
  };
}
