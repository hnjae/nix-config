{...}: {
  xdg.desktopEntries."org.fcitx.fcitx5-migrator" = {
    name = "fcitx5-migration-wizard";
    comment = "this should not be displayed";
    exec = ":";
    type = "Application";
    noDisplay = true;
  };
}
