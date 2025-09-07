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

    realesrgan-ncnn-vulkan # ai
    # openai-whisper # ai
  ])
]
