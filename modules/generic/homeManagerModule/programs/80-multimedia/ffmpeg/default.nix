{
  pkgs,
  config,
  ...
}: {
  home.packages = [
    # ffmpeg
    ((import ./package.nix) {inherit config pkgs;})
    # (pkgs.callPackage ./package.nix {})
  ];
}
