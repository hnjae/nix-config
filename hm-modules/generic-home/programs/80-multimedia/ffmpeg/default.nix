{
  config,
  pkgs,
  ...
}: {
  home.packages = [
    # ffmpeg
    ((import ./package.nix) {inherit config pkgs;})
  ];
}
