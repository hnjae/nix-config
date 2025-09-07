{
  ...
}:
{
  imports = [
    ./ffmpeg
    ./mpv
    ./yacreader

    ./50-audio.nix
    ./50-video-and-image.nix
  ];

  services.flatpak.packages = [
    "com.obsproject.Studio"
  ];
}
