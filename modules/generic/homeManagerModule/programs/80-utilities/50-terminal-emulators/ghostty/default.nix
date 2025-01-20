{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.ghostty.packages.${pkgs.stdenv.system}.default
  ];

  # NOTE:  <2024-12-30>
  # https://github.com/ghostty-org/ghostty/discussions/3628
  xdg.dataFile."applications/com.mitchellh.ghostty.desktop".text = ''
    [Desktop Entry]
    Name=Ghostty
    Type=Application
    Comment=A terminal emulator
    Exec=env GTK_IM_MODULE="wayland" ghostty
    Icon=com.mitchellh.ghostty
    Categories=System;TerminalEmulator;
    Keywords=terminal;tty;pty;
    StartupNotify=true
    Terminal=false
    Actions=new-window;
    X-GNOME-UsesNotifications=true
    X-TerminalArgExec=-e
    X-TerminalArgTitle=--title=
    X-TerminalArgAppId=--class=
    X-TerminalArgDir=--working-directory=
    X-TerminalArgHold=--wait-after-command

    [Desktop Action new-window]
    Name=New Window
    Exec=env GTK_IM_MODULE="wayland" ghostty
  '';
}
