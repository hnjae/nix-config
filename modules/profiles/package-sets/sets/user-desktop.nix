{ lib, ... }:
pkgs:
lib.flatten [
  pkgs.mkvtoolnix

  (with pkgs.unstable; [
    pkgs.unstable.gpac # modify mp4
    (lib.hiPrio (
      # hide gpac's desktop file
      pkgs.makeDesktopItem {
        name = "gpac";
        desktopName = "This should not be displayed.";
        exec = ":";
        noDisplay = true;
      }
    ))

    beets # organize music collection
    rsgain # Calculates ReplayGain, use this instead of vorbisgain, mp3gain and aacgain
    flac
    opusTools
    vorbis-tools

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

  pkgs.resources # pretty system info
  # pkgs.unstable.scrcpy # display and control android

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
  # Obsidian                       #
  ##################################

  # install as linux package to use https://github.com/hideakitai/obsidian-vim-im-control
  (lib.lists.optional pkgs.config.allowUnfree (
    pkgs.unstable.obsidian.override {
      commandLineArgs = builtins.concatStringsSep " " [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform-hint=auto"
        "-enable-wayland-ime"
        "--wayland-text-input-version=3"
      ];
    }
  ))
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
        exec = ''sh -c "exec wezterm start --class=${appId} --cwd=\"/home/hnjae/Projects/obsidian/home\" -e nvim ."'';
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
    # (lib.hiPrio (
    #   /*
    #     <NixOS 25.05>
    #
    #     xdg-open 이 KDE 환경에서 아래와 같은 로그로 journal 를 오염시켜서 handlr 로 대체.
    #
    #     ```
    #     "DecorationHover" - conversion from ",," to QColor failed  (integer conversion failed)
    #     ```
    #
    #     - xdg-open 과 동작 일치화:
    #       - xdg-open 은 `--` 인자를 처리 못함.
    #       - xdg-open 은 여러개의 인자를 받지 않음.
    #   */
    #   pkgs.writeScriptBin "xdg-open" ''
    #     #!${pkgs.dash}/bin/dash
    #
    #     if [ "$#" -ne 1 ]; then
    #       echo "xdg-open (handlr wrapped): only single argument is supported" >&2
    #       exit 1
    #     fi
    #
    #     case "$1" in
    #       "--help" | "--manual" | "--version" )
    #       exec "${pkgs.xdg-utils}/bin/xdg-open" "$1"
    #       ;;
    #     esac
    #
    #     exec ${pkgs.handlr-regex}/bin/handlr open -- "$1"
    #   ''
    # ))
    (pkgs.runCommandLocal "gtk-launch" { } ''
      mkdir -p "$out/bin"
      ln -s "${pkgs.gtk3}/bin/gtk-launch" "$out/bin/gtk-launch"
    '')
  ])
]
