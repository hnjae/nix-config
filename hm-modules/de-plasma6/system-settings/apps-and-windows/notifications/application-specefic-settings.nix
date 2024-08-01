{...}: {
  programs.plasma.configFile."plasmanotifyrc" = {
    "Services/plasma_workspace" = {
      "ShowInHistory".value = true;
      "ShowPopups".value = true;
    };
  };
}
