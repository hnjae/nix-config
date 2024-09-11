{...}: {
  # NOTE: ~/.config/plasma-org.kde.plasma.desktop-appletsrc
  # /run/current-system/sw/lib/qt-6/plugins/plasma/applets
  # /run/current-system/sw/share/plasma/plasmoids
  programs.plasma.panels = [
    {
      height = 26;
      location = "top";
      alignment = "center";
      floating = false;
      screen = "all";
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
      screen = "all";
      widgets = [
        {
          name = "org.kde.plasma.icontasks";
          config = {
            General = {
              fill = "false";
              reverseMode = "false";
              launchers = [
                "applications:org.kde.konsole.desktop"
                "applications:brave-browser.desktop"
                "applications:com.logseq.Logseq.desktop"
                "applications:chrome-lobe.hjae.xyz__-Default.desktop"
                "applications:brave-ticktick.com__webapp-Default.desktop"
                # "applications:com.ticktick.TickTick.desktop"
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

