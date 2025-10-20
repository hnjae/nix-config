/*
  README:

  GUI 앱들. 이들은 다른 배포판에서 사용하면 이슈생길 가능성이 높다.
*/
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
          xorg.libxshmfence # for whooing-1.10.0 2025-10-19
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
  pkgs.qdirstat

  (lib.lists.optionals pkgs.config.allowUnfree [
    pkgs.davinci-resolve
    pkgs.my.cider-2
    pkgs.unstable.warp-terminal
  ])
  (lib.lists.optionals pkgs.hostPlatform.isLinux [
    pkgs.wezterm
    pkgs.unstable.ghostty
    (pkgs.runCommandLocal "kitten" { } ''
      mkdir -p "$out/bin"
      ln -s "${pkgs.kitty}/bin/kitten" "$out/bin/kitten"
    '')
  ])
]
