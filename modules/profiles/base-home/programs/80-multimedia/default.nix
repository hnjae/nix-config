{
  ...
}:
{
  imports = [
    ./cider-2.nix
    ./ffmpeg
    ./kooha.nix
    ./mpv
    ./yacreader

    ./50-audio.nix
    ./50-video-and-image.nix
    ./99-console.nix
  ];

  services.flatpak.packages = [
    "com.obsproject.Studio"
  ];
}
