{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDesktop {
    home.packages = [
      pkgsUnstable.ghostty

      (pkgs.runCommandLocal "kitten" { } ''
        mkdir -p "$out/bin"
        ln -s "${pkgs.kitty}/bin/kitten" "$out/bin/kitten"
      '')
    ];
    default-app.fromApps = [ "com.mitchellh.ghostty" ];

    /*
      NOTE: IME Status <2025-02-06>

      Use text-input-v3

      https://github.com/ghostty-org/ghostty/discussions/3628
      https://github.com/ghostty-org/ghostty/discussions/3279
    */
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
  };
}
