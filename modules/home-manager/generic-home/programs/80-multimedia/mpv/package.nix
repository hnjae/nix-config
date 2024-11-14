{pkgs, ...}:
pkgs.mpv-unwrapped.override {
  alsaSupport = false;
  pulseSupport = false;
  jackaudioSupport = false;
  sdl2Support = false;
  vdpauSupport = false;
  x11Support = false;
  #
  cddaSupport = true; # default false
  sixelSupport = true; # default false
  vapoursynthSupport = pkgs.stdenv.isx86_64; # default false
}
