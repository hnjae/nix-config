{...}: {
  programs.plasma.configFile.kdeglobals.General = {
    TerminalApplication = "konsole";
    TerminalService = "org.kde.konsole.desktop";
  };
}
