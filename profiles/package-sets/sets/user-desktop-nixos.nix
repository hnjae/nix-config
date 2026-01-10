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
    mesa-demos # glxinfo
    vulkan-tools
    wayland-utils
    libva-utils
    xorg.xdpyinfo # prints display
    xorg.xwininfo # prints xwindow info

    # gui apps
    my.xdg-terminal-exec

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
    # pkgs.davinci-resolve
    pkgs.my.cider-2
    pkgs.unstable.warp-terminal
  ])

  [
    pkgs.alacritty-graphics # sixel and iTerm2 patched alacritty
    (lib.hiPrio (
      pkgs.runCommandLocal "alacritty-icon-fix" { } ''
        mkdir -p "$out/share/icons/hicolor/scalable/apps/"

        app_id='Alacritty'
        icon="${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/''${app_id}.svg"

        cp --reflink=auto \
          "$icon" \
          "$out/share/icons/hicolor/scalable/apps/''${app_id}.svg"

        for size in 16 22 24 32 48 64 96 128 256 512; do
          mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps/"

          '${pkgs.librsvg}/bin/rsvg-convert' \
            --keep-aspect-ratio \
            --height="$size" \
            --output="$out/share/icons/hicolor/''${size}x''${size}/apps/''${app_id}.png" \
            "$icon"
        done
      ''
    ))
  ]
  [
    pkgs.wezterm
    (lib.hiPrio (
      pkgs.runCommandLocal "wezterm-icon-fix" { } ''
        mkdir -p "$out/share/icons/hicolor/scalable/apps/"

        app_id='org.wezfurlong.wezterm'
        icon="${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/''${app_id}.svg"

        cp --reflink=auto \
          "$icon" \
          "$out/share/icons/hicolor/scalable/apps/''${app_id}.svg"

        for size in 16 22 24 32 48 64 96 128 256 512; do
          mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps/"

          '${pkgs.librsvg}/bin/rsvg-convert' \
            --keep-aspect-ratio \
            --height="$size" \
            --output="$out/share/icons/hicolor/''${size}x''${size}/apps/''${app_id}.png" \
            "$icon"
        done
      ''
    ))
  ]
  (lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
    (pkgs.ghostty.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        substituteInPlace $out/share/applications/com.mitchellh.ghostty.desktop \
          --replace-fail " --gtk-single-instance=true" ""
      '';
    }))
  ])
]
