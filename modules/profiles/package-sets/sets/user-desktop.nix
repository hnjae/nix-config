{ lib, ... }:
pkgs:
lib.flatten [
  pkgs.mkvtoolnix

  (with pkgs.unstable; [
    gpac # modify mp4
    # hide gpac's desktop file
    (lib.hiPrio (
      pkgs.makeDesktopItem {
        name = "gpac";
        desktopName = "This should not be displayed.";
        exec = ":";
        noDisplay = true;
      }
    ))

    opusTools
    vorbis-tools
    flac
    rsgain # Calculates ReplayGain

    libheif
    libavif
    libjxl
    librsvg

    zopfli
    libvmaf
    libwebp
    mozjpeg
    imagemagick

    pandoc

  ])
  pkgs.unstable.realesrgan-ncnn-vulkan # ai
  # pkgs.unstable.openai-whisper # ai
  pkgs.unstable.ocrmypdf
  pkgs.unstable.img2pdf

  pkgs.resources
  pkgs.unstable.scrcpy # display and control android

  pkgs.zathura
  (lib.hiPrio (
    pkgs.runCommandLocal "zathura-icon-fix" { } ''
      mkdir -p "$out/share/icons/hicolor/scalable/apps/"

      icon='${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/org.pwmt.zathura.svg'
      app_id='org.pwmt.zathura'

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

  ##################################
  # Obsidian Nvim                  #
  ##################################
  (
    let
      appId = "obsidian-nvim";
      # icon = "${pkgs.pantheon.elementary-icon-theme}/share/icons/elementary/apps/128/utilities-system-monitor.svg";
      # icon = "${pkgs.whitesur-icon-theme}/share/icons/WhiteSur/apps/scalable/accessories-notes.svg";
      icon = "${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/org.standardnotes.standardnotes.svg";
    in
    [
      (pkgs.runCommandLocal appId { } ''
        mkdir -p "$out/share/icons/hicolor/scalable/apps/"

        cp --reflink=auto \
          "${icon}" \
          "$out/share/icons/hicolor/scalable/apps/${appId}.svg"
      '')
      (pkgs.makeDesktopItem {
        genericName = "Obsidian Nvim";
        name = appId;
        desktopName = appId;
        categories = [ "Office" ];
        exec = ''sh -c "exec wezterm start --class=${appId} --cwd=\"\\$HOME/Projects/obsidian/home\" -e nvim ."'';
        icon = appId;
      })
    ]
  )

  ##################################
  # MISC                           #
  ##################################
  (lib.lists.optionals pkgs.hostPlatform.isLinux [
    pkgs.poppler_utils # pdftotext
    pkgs.clipboard-jh
    pkgs.handlr-regex
    (pkgs.runCommandLocal "gtk-launch" { } ''
      mkdir -p "$out/bin"
      ln -s "${pkgs.gtk3}/bin/gtk-launch" "$out/bin/gtk-launch"
    '')
  ])
]
