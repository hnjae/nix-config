{ pkgs, ... }:
{
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  home-manager.sharedModules = [
    {
      dconf.settings."org/gnome/shell".enabled-extensions = [
        "gsconnect@andyholmes.github.io"
      ];
    }
    (
      { config, ... }:
      {
        stateful.nodes = [
          {
            path = "${config.xdg.configHome}/gsconnect";
            mode = "755";
            type = "dir";
          }
        ];
      }
    )
  ];
}
