{
  pkgs,
  config,
  ...
}: let
  schema = pkgs.gsettings-desktop-schemas;
  datadir = "${schema}/share/gsettings-schemas/${schema.name}";
in {
  # imports = [
  #   ./_fcitx-wayland.nix
  # ];
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [fcitx5-gtk fcitx5-mozc fcitx5-hangul fcitx5-m17n fcitx5-lua];
  };

  programs.sway = {
    enable = true;
    extraOptions = [
      "--unsupported-gpu"
    ];
    extraPackages = with pkgs; [
      blueman
      networkmanagerapplet
      # firewalld-gui
      rxvt-unicode-unwrapped

      playerctl
      grim

      waybar
      wofi
      swayidle
      swaylock
      swaynotificationcenter
      eww-wayland
      # dunst

      # hardware info
      glxinfo
      vulkan-tools
      wayland-utils
      xorg.xdpyinfo

      # misc
      copyq
      flameshot
      ddcutil
      ulauncher
      stow
      pulseaudio # for pactl

      # themes
      # gsettings-desktop-schemas
      bibata-cursors
      glib # gsettings
      lxappearance
      icon-theme-fluent
      icon-theme-whitesur
      gnome.adwaita-icon-theme
    ];
    extraSessionCommands = ''
      export XDG_DATA_DIRS="${datadir}:$XDG_DATA_DIRS"
    '';
  };

  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    # xdg-desktop-portal-wlr

    # org.freedesktop.portal.OpenURI 지원
    xdg-desktop-portal-gtk
  ];

  # services.greetd = {
  #   enable = false;
  #   vt = 3;
  #   settings = {
  #     default_session = {
  #       # command = "cage -s -- regreet";
  #       command = "${pkgs.greetd.greetd}/bin/agreety --cmd Hyprland";
  #     };
  #   };
  # };

  programs.dconf.enable = true;
  services.fwupd.enable = true;

  services.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    settings.X11.ServerArguments = "-nolisten tcp -dpi 192";
    settings.Theme.CursorTheme = "Bibata-Modern-Ice";
    settings.Theme.CursorSize = 48;
  };

  # keyring
  programs.seahorse.enable = config.services.gnome.gnome-keyring.enable;
  services.gnome.gnome-keyring.enable = true;
}
