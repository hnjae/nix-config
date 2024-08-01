{
  pkgs,
  pkgsUnstable,
  ...
}: {
  home.packages = with pkgsUnstable; [
    realesrgan-ncnn-vulkan
    libheif
    libavif
    libjxl

    openai-whisper

    zopfli
    libvmaf
    libwebp
    mozjpeg
    # cavif-rs
    imagemagick

    pandoc

    librsvg
  ];
}
