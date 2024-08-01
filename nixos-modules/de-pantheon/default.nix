{
  pkgs,
  config,
  ...
}: let
  themes = with pkgs; [
    bibata-cursors
  ];
in {
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [fcitx5-gtk fcitx5-mozc fcitx5-hangul fcitx5-m17n fcitx5-lua];
  };

  services.xserver.displayManager.lightdm = {
    inherit (config.services.xserver.desktopManager.pantheon) enable;

    # greeters.slick = {
    #   enable = true;
    #   font.package = pkgs.pretendard;
    #   font.name = "Pretendard 11";
    #   # theme.package = pkgs.fluent-gtk-theme;
    #   # theme.name = "Fluent-Dark";
    #   # iconTheme.package = pkgs.icon-theme-fluent;
    #   # iconTheme.name = "Fluent-dark";
    #   cursorTheme.package = pkgs.bibata-cursors;
    #   cursorTheme.size = 48;
    #   cursorTheme.name = "Bibata-Modern-Ice";
    #   # https://github.com/linuxmint/slick-greeter
    #   extraConfig = ''
    #     xft-dpi=192
    #     enable-hidpi=on
    #     play-ready-sound=true
    #     screen-reader=false
    #     show-a11y=false
    #     draw-grid=true
    #   '';
    # };
  };

  services.xserver.desktopManager.pantheon = {
    enable = true;
    # extraGSettingsOverrides = ''
    #   [org.gnome.desktop.interface]
    #   scaling-factor=2
    # '';
  };

  qt.platformTheme = "gnome";
  programs.dconf.enable = true;

  # programs.kdeconnect = {
  #   enable = false;
  #   package = pkgs.gnomeExtensions.gsconnect;
  # };

  environment.systemPackages = themes;
}
