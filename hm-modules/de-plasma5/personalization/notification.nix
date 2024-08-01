{...}: {
  programs.plasma.configFile."plasmanotifyrc" = {
    "Notifications"."PopupTimeout".value = 4000;

    # notifications - Application-specific settings - plasma workspace
    # flatpak 앱 실행시 뜨는 noti 끄기
    "Services.plasma_workspace" = {
      "ShowInHistory".value = true;
      "ShowPopups".value = true;
    };
  };
}
