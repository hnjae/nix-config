{
  pkgs,
  pkgsUnstable,
  ...
}: {
  home.packages = with pkgsUnstable; [
    gpac # modify mp4
    opusTools
    vorbis-tools
    flac
    rsgain # Calculates ReplayGain

    libheif
    libavif
    libjxl

    zopfli
    libvmaf
    libwebp
    mozjpeg
    # cavif-rs
    imagemagick

    pandoc

    librsvg

    # ai
    realesrgan-ncnn-vulkan
    # openai-whisper
  ];
}
