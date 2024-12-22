{
  pkgs,
  pkgsUnstable,
  ...
}: {
  home.packages = with pkgsUnstable; [
    gpac

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
    openai-whisper
  ];
}
