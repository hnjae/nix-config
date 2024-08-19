{
  pkgs,
  config,
  ...
}:
pkgs.mpv-unwrapped.override {
  alsaSupport = false;
  pulseSupport = false;
  jackaudioSupport = false;
  sdl2Support = false;
  xvSupport = false;
  vdpauSupport = false;
  xineramaSupport = pkgs.stdenv.isLinux;
  cddaSupport = true; # default false
  sixelSupport = true; # default false
  vapoursynthSupport = pkgs.stdenv.isx86_64; # default false
  ffmpeg = (import ../ffmpeg/package.nix) {inherit config pkgs;};
}
