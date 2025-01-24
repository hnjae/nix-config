{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    gnomeExtensions.dash-to-panel
    # gnomeExtensions.dash-to-dock
    # gnomeExtensions.dock-from-dash
  ];
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = [
      "dash-to-panel@jderose9.github.com"
    ];
    "org/gnome/shell/extensions/dash-to-panel" = {
      #################
      # group windows #
      #################
      # style
      appicon-margin = 4;
      appicon-padding = 6;
      dot-position = "TOP";
      dot-style-focused = "DOTS";
      dot-style-unfocused = "DOTS";
      # panel-anchors = ''
      #   {"0":"MIDDLE","1":"MIDDLE","2":"MIDDLE"}
      # '';
      # panel-lengths = ''
      #   {"0":100,"1":100,"2":100}
      # '';
      panel-positions = ''{"0":"TOP","1":"TOP","2":"TOP"}'';
      panel-sizes = ''{"0":32,"1":32,"2":32}'';

      # workspace & monitors
      isolate-monitors = false;
      multi-monitors = false;
      isolate-workspaces = true;

      ###################
      # ungroup windows #
      ###################
      # dot-position = "TOP";
      # group-apps = false;
      # group-apps-label-font-size = 13;
      # group-apps-label-font-weight = "inherit";
      # group-apps-underline-unfocused = false;
      # group-apps-use-fixed-width = true;
      # group-apps-use-launchers = false;
      # isolate-workspaces = true;
      # isolate-monitors = false;
      # multi-monitors = false;
      # panel-sizes = ''
      #   {"0":24,"1":24,"2":24}
      # '';
    };
  };
}
