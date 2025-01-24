{pkgs, ...}: {
  home.packages = [pkgs.gnomeExtensions.rectangle];
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = ["rectangle@acristoffers.me"];
    "org/gnome/shell/extensions/rectangle" = {
      tile-maximize = [];
      tile-maximize-almost = ["<Control><Super>Return"];
      tile-quarter-centered = ["<Control><Super><Alt>Return"];
      # Quarter Grid ( <C-D> + UIJK )
      # tile-quarter-bottom-left = ["<Control><Super>n"];
      # tile-quarter-bottom-right = ["<Control><Super>e"];
      # tile-quarter-top-left = ["<Control><Super>l"];
      # tile-quarter-top-right = ["<Control><Super>u"];
      tile-quarter-bottom-left = [];
      tile-quarter-bottom-right = [];
      tile-quarter-top-left = [];
      tile-quarter-top-right = [];
      # Sixth Grid ( <S-C-D> )
      tile-sixth-bottom-center = [];
      tile-sixth-bottom-left = [];
      tile-sixth-bottom-right = [];
      tile-sixth-top-center = [];
      tile-sixth-top-left = [];
      tile-sixth-top-right = [];
      # Ninth Grid ( <C-A-D> )
      tile-ninth-bottom-center = [];
      tile-ninth-bottom-left = [];
      tile-ninth-bottom-right = [];
      tile-ninth-middle-center = [];
      tile-ninth-middle-left = [];
      tile-ninth-middle-right = [];
      tile-ninth-top-center = [];
      tile-ninth-top-left = [];
      tile-ninth-top-right = [];
      # Halves ( <C-D> + Arrow )
      tile-half-bottom = [];
      tile-half-center-horizontal = [];
      tile-half-center-vertical = [];
      tile-half-left = [];
      tile-half-right = [];
      tile-half-top = [];
      # Thirds ( <S-C> + DFG/ERT )
      # tile-third-first = ["<Control><Super>s"];
      # tile-third-second = ["<Control><Super>t"];
      # tile-third-third = ["<Control><Super>g"];
      # tile-two-thirds-center = ["<Control><Super>p"];
      # tile-two-thirds-left = ["<Control><Super>f"];
      # tile-two-thirds-right = ["<Control><Super>b"];
      tile-third-first = ["<Control><Super>h"];
      tile-third-second = ["<Control><Super>comma"];
      tile-third-third = ["<Control><Super>period"];
      tile-two-thirds-center = ["<Control><Super>u"];
      tile-two-thirds-left = ["<Control><Super>l"];
      tile-two-thirds-right = ["<Control><Super>y"];
      # Fourths ( <C-D> + VBNM )
      tile-fourth-first = [];
      tile-fourth-fourth = [];
      tile-fourth-second = [];
      tile-fourth-third = [];
      tile-three-fourths-left = [];
      tile-three-fourths-right = [];
      # Move Tiled Window
      tile-center = ["<Control><Super>e"];
      tile-move-bottom = [];
      tile-move-bottom-left = [];
      tile-move-bottom-right = [];
      tile-move-left = [];
      tile-move-right = [];
      tile-move-top = [];
      tile-move-top-left = [];
      tile-move-top-right = [];
      tile-move-to-monitor-bottom = [];
      tile-move-to-monitor-left = [];
      tile-move-to-monitor-right = [];
      tile-move-to-monitor-top = [];
      # Stretch Window ( <C-M-D> + Arrow )
      tile-stretch-bottom = [];
      tile-stretch-left = [];
      tile-stretch-right = [];
      tile-stretch-top = [];
      # Stretch Window - Step ( <C-D> + Number )
      tile-stretch-step-bottom = [];
      tile-stretch-step-bottom-left = [];
      tile-stretch-step-bottom-right = [];
      tile-stretch-step-left = [];
      tile-stretch-step-right = [];
      tile-stretch-step-top = [];
      tile-stretch-step-top-left = [];
      tile-stretch-step-top-right = [];
    };
  };
}
