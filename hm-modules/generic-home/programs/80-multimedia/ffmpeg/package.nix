{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in
  pkgs.ffmpeg.override {
    withHeadlessDeps = true;
    withSmallDeps = true;
    withUnfree = pkgs.config.allowUnfree;

    withCuda = false;
    withCudaLLVM = false;
    withNvdec = false;
    withNvenc = false;
    withVdpau = false;

    withAlsa = false;
    withPulse = false;
    withSdl2 = false;

    withFontconfig = false;
    withFreetype = false;
    withSsh = false;

    # withPlacebo = ! isDarwin;

    withVulkan = !isDarwin;
    withOpencl = true;

    withAom = true;
    withRav1e = true;
    withSvtav1 = !pkgs.stdenv.isAarch64;
    withTheora = false;
    withXvid = false;

    withVoAmrwbenc = true;
    withOpencoreAmrnb = true;
    withGsm = true;
    withGme = true;
    withFdkAac = true;

    withWebp = true;
    withSvg = true;
    withOpenjpeg = true; # jpeg2000 de/encoder

    withXml2 = true;
    withBluray = true;

    withVmaf = !pkgs.stdenv.isAarch64;

    # filter
    withVidStab = true;
    withGrayscale = true;
    withLadspa = true;
  }
