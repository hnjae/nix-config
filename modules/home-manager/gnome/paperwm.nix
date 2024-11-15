{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    gnomeExtensions.paperwm
  ];

  # run `dconf dump /org/gnome/shell/extensions/paperwm/`
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = [
      "paperwm@paperwm.github.com"
    ];
    "org/gnome/desktop/wm/keybindings" = {
      minimize = []; # @as []
    };
    "org/gnome/shell/extensions/paperwm" = {
      # Border
      select-border-size = 16;
      selection-border-radius-top = 12;
      selection-border-radius-bottom = 12;

      # Gap
      window-gap = 4;
      vertical-margin = 2;
      horizontal-margin = 4;
      vertical-margin-bottom = 2;

      #
      show-window-position-bar = false;

      # gesture-horizontal-fingers = 3;
      # gesture-workspace-fingers = 3;
      # winprops=['{"wm_class":"1password","scratch_layer":true,"title":"1Password"}']

      # winprops = lib.hm.gvariant.mkArray [
      #   (
      #     lib.hm.gvariant.mkDictionaryEntry {
      #       wm_class = "1password";
      #       title = "1Password";
      #       scratch_layer = true;
      #     }
      #   )
      # ];

      # winprops = [
      #   {
      #     wm_class = "1password";
      #     title = "1Password";
      #     scratch_layer = true;
      #   }
      # ];

      cycle-width-steps = [
        500.0
        700.0
        810.0
        1010.0
        1500.0
      ];
    };
    "org/gnome/shell/extensions/paperwm/keybindings" = {
      cycle-width = ["<Super>r"];
      cycle-width-backwards = ["<Shift><Super>r"];
      cycle-height = ["'<Alt><Super>r'"];
      cycle-height-backwards = ["<Shift><Alt><Super>r"];
      # toggle-scratch-layer=['<Shift><Super>Escape']
    };
  };
}
