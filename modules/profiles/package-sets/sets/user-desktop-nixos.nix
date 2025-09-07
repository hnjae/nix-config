{ lib, ... }:
pkgs:
lib.flatten [
  (with pkgs; [
    firefox
    vdhcoapp
    (chromium.override {
      # NOTE: 이거 빌드 안될 때 많다. <2025-08-21>
      enableWideVine = false;
    })
    (brave.override {
      commandLineArgs = builtins.concatStringsSep " " [
        "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
        "-enable-wayland-ime"
        "--wayland-text-input-version=1"
      ];
    })

    # infos
    clinfo # opencl
    glxinfo
    vulkan-tools
    wayland-utils
    libva-utils
    xorg.xdpyinfo # prints display
    xorg.xwininfo # prints xwindow info

    # gui apps
    my.xdg-terminal-exec
    kdiskmark

    (appimage-run.override {
      extraPkgs =
        pkgs: with pkgs; [
          libthai
          # libsecret
        ];
    })

    glib # for gio

    # xev
    # xorg.xev
    wev

    # common tools
    wl-clipboard
    xclip
    xsel
    wmctrl
    libnotify # notify-send command

  ])

  (lib.lists.optionals pkgs.config.allowUnfree [
    pkgs.davinci-resolve
    pkgs.my.cider-2
  ])
]
