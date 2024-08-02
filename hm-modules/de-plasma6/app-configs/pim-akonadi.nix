{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.configHome}/akonadi";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.configHome}/specialmailcollectionsrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/mailtransports";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kabldaprc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/merkuro.calendarrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/akregatorrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/phishingurlrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kontactrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/emaildefaults";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/defaultcalendarrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kmailsearchindexingrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kalendarrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kalendaracrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kaddressbookrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/eventviewsrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/akonadi-firstrunrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/akonadi_contactrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/akonadi_indexing_agentrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/emailidentities";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/foldermailarchiverc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kmail2rc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kontact_summaryrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/korganizerrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.dataHome}/akonadi";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/akonadi_migration_agent";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.configHome}/Unknown Organization";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/akregator";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/kmail2";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/KDE/merkuro.calendar";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/kontact";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/kpeople";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/kpeoplevcard";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/local-mail";
      mode = "755";
      type = "dir";
    }
  ];
  stateful.nocowNodes = [
    {
      path = "${config.xdg.dataHome}/phishingurl";
      mode = "755";
      type = "dir";
    }
  ];

  # systemd.tmpfiles.rules = [
  #   ''R "${config.xdg.dataHome}/KDE/merkuro.calendar/merkuro.calendarstaterc''
  # ];
}
