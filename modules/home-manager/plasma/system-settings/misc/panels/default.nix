{config, ...}: {
  # NOTE: ~/.config/plasma-org.kde.plasma.desktop-appletsrc
  # /run/current-system/sw/lib/qt-6/plugins/plasma/applets
  # /run/current-system/sw/share/plasma/plasmoids
  # NOTE: screen = "all" 은 애로 사항 多. e.g. 제대로 작동 X, 한 화면에 동일 패널 뜸 <2024-11-12>
  programs.plasma.panels = [
    {
      height = 26;
      location = "top";
      alignment = "center";
      floating = false;
      screen = [0];
      widgets = [
        "org.kde.plasma.marginsseparator"
        (import ./widgets/kicker-dash.nix)

        # "org.kde.plasma.marginsseparator"
        # (import ./widgets/show-activity-manager.nix)

        "org.kde.plasma.marginsseparator"
        (import ./widgets/compact-pager.nix)
        "org.kde.plasma.marginsseparator"

        (import ./widgets/app-menu.nix)

        "org.kde.plasma.panelspacer"

        # (import ./widgets/icon-tasks-alt.nix)

        # "org.kde.plasma.marginsseparator"

        (import ./widgets/system-tray.nix)
        (import ./widgets/digital-clock.nix)
        "org.kde.plasma.showdesktop"
      ];
    }
    {
      height = 40;
      location = "bottom";
      alignment = "center";
      lengthMode = "fit";
      floating = true;
      hiding = "dodgewindows";
      screen = [0];
      widgets = [
        {
          name = "org.kde.plasma.icontasks";
          config = {
            General = {
              fill = "false";
              reverseMode = "false";
              launchers =
                (
                  if (config.default-app.browser != null)
                  then [
                    "applications:${config.default-app.browser}.desktop"
                  ]
                  else [
                    "applications:org.mozilla.firefox.desktop"
                  ]
                )
                ++ [
                  "applications:org.kde.konsole.desktop"
                  "applications:com.logseq.Logseq.desktop"
                  "applications:chrome-lobe.hjae.xyz__-Default.desktop"
                  # "applications:brave-ticktick.com__webapp-Default.desktop"
                  "applications:com.ticktick.TickTick.desktop"
                  "applications:chrome-calendar.notion.so__-Default.desktop"
                  "applications:org.mozilla.Thunderbird.desktop"
                  "applications:1password.desktop"
                ];
            };
          };
        }
      ];
    }
  ];
}
# NOTE:
/*
단축키는 아래 처럼 형성됨. plasma-manager 24.05 에서는 아직 취급 불가능.

[Containments][2][Applets][34][Shortcuts]
global=Meta+F
*/
