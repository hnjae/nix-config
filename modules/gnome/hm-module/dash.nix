{
  pkgs,
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

    "org/gnome/shell/extensions/dash-to-panel" =
      let
        monitors = [
          "GSM-0x01010101" # isis's monitor
          "BNQ-ET83K02766SL0"
          "CYS-0x00000055" # 16 inch monitor
          "LGD-0x00000000" # 24 inch fhd monitor
        ];
      in
      {
        hot-keys = true; # shows number on the app icon

        #################
        # group windows #
        #################
        # style
        appicon-margin = 4;
        appicon-padding = 6;
        dot-position = "TOP";
        dot-style-focused = "DOTS";
        dot-style-unfocused = "DOTS";

        panel-positions = builtins.toJSON ((lib.genAttrs monitors (_: "TOP")));
        panel-sizes = builtins.toJSON ((lib.genAttrs monitors (_: "32")));

        # workspace & monitors
        isolate-monitors = false;
        multi-monitors = true;
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
