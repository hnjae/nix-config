{...}: {
  services.displayManager.defaultSession = "plasma";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    enableHidpi = true;
    settings = {
      Users = {
        RememberLastUser = true;
        RememberLastSession = false;
      };
      General = {
        # GreeterEnvironment = "QT_SCREEN_SCALE_FACTORS=1.5,QT_FONT_DPI=144";
        # GreeterEnvironment = "QT_SCREEN_SCALE_FACTORS=1.5";
      };
      Theme = {
        # Current = "";
        # ThemeDir = "${pkgs.xxx}/share/sddm/themes";
      };
    };
  };
}
