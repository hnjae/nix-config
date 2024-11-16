{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    gnomeExtensions.paperwm
    gnomeExtensions.vertical-workspaces
  ];

  # run `dconf dump /org/gnome/shell/extensions/paperwm/`
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = [
      "paperwm@paperwm.github.com"
      "vertical-workspaces@G-dH.github.com"
    ];
    "org/gnome/shell/extensions/vertical-workspaces" = {
      # dash position
      dash-position = 3;
      dash-position-adjust = 0;
      dash-max-icon-size = 48;
      dash-show-windows-before-activation = 3; # prefer-current-workspace
      # workspace position
      ws-thumbnails-position = 1;
      wst-position-adjust = 0;
      #
      app-grid-order = 1; # 사전 순
      app-folder-order = 1; # 사전 순
      #
      overview-bg-blur-sigma = 0; # paperwm 에서 blur 가 없으니 일체감을 위해.
      ws-switcher-wraparound = false; # 첫번째 ws 에서 마지막 ws 로 랩핑. paperwm 에서 지원 안하니 사용X
      # animation
      app-grid-animation = 0;
      workspace-animation = 0;
      search-view-animation = 0;
      # modules
      app-display-module = true;
      dash-module = true;
      app-favorites-module = false;
      layout-module = false;
      message-tray-module = false;
      osd-window-module = false;
      overlay-key-module = false;
      panel-module = false;
      search-controller-module = false;
      search-module = false;
      swipe-tracker-module = false;
      win-attention-handler-module = false;
      window-manager-module = false;
      window-preview-module = false;
      workspace-animation-module = false;
      workspace-module = false;
      workspace-switcher-popup-module = false;
    };
    "org/gnome/mutter" = {
      overlay-key = ""; # disable meta key to overlay
    };
    "org/gnome/shell/keybindings" = {
      toggle-overview = ["<Super>w"]; # use super-w key to view overlay
    };
    "org/gnome/desktop/wm/keybindings" = {
      minimize = []; # @as []
    };
    "org/gnome/shell/extensions/paperwm" = {
      # Border
      select-border-size = 3; # default: 10
      selection-border-radius-top = 12;
      selection-border-radius-bottom = 12;

      # Gap
      window-gap = 5;
      horizontal-margin = 5; # margin with screen-edge
      vertical-margin = 5;
      vertical-margin-bottom = 5;

      # top bar
      show-window-position-bar = false;
      disable-topbar-styling = true;
      use-default-background = true;

      #
      animation-time = 0.0;

      # gestures
      gesture-workspace-fingers = 0; # disable
      gesture-horizontal-fingers = 3;
      swipe-sensitivity = [3.0 2.0];

      winprops = [
        ''{"wm_class":"1password","title":"1Password","scratch_layer":true}''
      ];

      cycle-width-steps = [
        500.0
        700.0
        810.0
        1010.0
        # 1500.0
      ];
    };
    "org/gnome/shell/extensions/paperwm/keybindings" = {
      # cycle-width = ["<Super>r"];
      # cycle-width-backwards = ["<Shift><Super>r"];
      # cycle-height = ["'<Alt><Super>r'"];
      # cycle-height-backwards = ["<Shift><Alt><Super>r"];
      # toggle-scratch-layer=['<Shift><Super>Escape']
    };
  };
}
