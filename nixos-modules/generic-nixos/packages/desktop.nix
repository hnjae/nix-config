{
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  inherit (lib) mkOverride;
  inherit (config.generic-nixos) isDesktop;
in {
  # managing android
  programs.adb.enable = mkOverride 999 isDesktop;

  environment.defaultPackages = lib.lists.optionals isDesktop (with pkgs; [
    glib # for gio

    # xev
    xorg.xev
    wev

    # common tools
    wl-clipboard
    xclip
    xsel
    wmctrl
    libnotify # notify-send command

    # for qt apps (such as contour)
    # qt6.qtwayland
    # libsForQt5.qt5.qtwayland

    # infos
    clinfo # opencl
    glxinfo
    vulkan-tools
    wayland-utils
    xorg.xdpyinfo

    # gui apps
    # alacritty
    xdg-terminal-exec

    # blackbox-terminal
    kdiskmark

    # webp support in various programs
    # gdk-pixbuf
    # webp-pixbuf-loader

    # others
    ddcutil
    ddcui

    #
    libva-utils
    # wlprop # xprop for wlroots

    (appimage-run.override {
      extraPkgs = pkgs:
        with pkgs; [
          libthai
          # libsecret
        ];
    })
  ]);
}
