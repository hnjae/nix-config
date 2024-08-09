{...}: {
  imports = [
    ./mpv
    ./ffmpeg
    ./qimgv

    ./kooha.nix
    ./obs-studio.nix

    ./50-audio.nix
    ./50-video-and-image.nix
    ./99-console.nix
  ];
}
