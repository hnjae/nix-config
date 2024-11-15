{
  pkgs,
  lib,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  default-app = {
    video = "mpv";
    audio = "mpv";
  };

  programs.mpv = {
    enable = genericHomeCfg.isDesktop;
    package = pkgs.mpv.overrideAttrs (_: {
      mpv = (import ./package.nix) {inherit config pkgs;};
      youtubeSupport = true;
      scripts = builtins.concatLists [
        (lib.lists.optionals pkgs.stdenv.isLinux
          (with pkgs.mpvScripts; [mpris]))
        (with pkgs.mpvScripts; [
          visualizer
          vr-reversal
          mpv-cheatsheet # type ? to see keybord shortcuts
        ])
      ];
    });

    defaultProfiles = ["gpu-hq"];
    config = {
      # do not disable compositor
      x11-bypass-compositor = false;

      ytdl-format = "bestvideo+bestaudio";
      hidpi-window-scale = true;
      #
      dither-depth = "auto";
      temporal-dither = true;

      #
      video-sync = "display-resample";

      # scale = "ewa_lanczossharp";
      scale = "ewa_lanczos";
      dscale = "mitchell";
      cscale = "mitchell"; # ignored by gpu-next?
      sigmoid-upscaling = true;
      correct-downscaling = true;

      # testing options
      error-diffusion = "burkes";

      #
      vo = "gpu-next";
      # ao = "pulse";
      ao =
        if pkgs.stdenv.isDarwin
        then "coreaudio"
        else "pipewire";
      af = "lavfi=[loudnorm]";
      pipewire-volume-mode = "global";
      gpu-api = "auto";
      vulkan-async-compute = true; # ! isNvidia
      # hwdec = "auto-copy";
      hwdec = "auto";
      # hwdec-codecs = "all";
      hr-seek = "default";
      sws-scaler = "spline";

      replaygain = "track";

      #
      osc = true;

      # osd
      term-osd-bar = true;
      osd-level = 1;
      osd-fractions = true; # show osd times with fractions of seconds
      osd-bar = false;
      osd-duration = 800; # default 1000
      osd-blur = 0.1; # default 0
      osd-scale-by-window = false;
      osd-font-size = 60; # default 55
      osd-font = "monospace";

      # sub
      sub-blur = 0.11;
      sub-font-size = 40; # default 55
      sub-ass-line-spacing = 25; # srt 자막에도 적용됨.
      sub-margin-x = 120; # default 25
      sub-ass-override = true; # 위 옵션적용
      sub-font = "KoreanCNMM";
      sub-border-size = 2.3; # default 3

      # sub-filter-sdh="yes" # remove deaf or hard-of-hearing subtitle
      # sub-filter-sdh-harder="yes"

      # behavior
      keep-open = true;

      # screenshot
      screenshot-format = "png";
      screenshot-tag-colorspace = true;
      screenshot-webp-lossless = true;
      screenshot-webp-quality = 100;
      screenshot-webp-compression = 6;
      screenshot-png-compression = 9;
      screenshot-template = "%F-%P-(%t%F)";
      screenshot-directory = "${
        # if (pkgs.stdenv.isLinux && config.xdg.userDirs.enable)
        if (config.xdg.userDirs.enable)
        then (config.xdg.userDirs.pictures)
        else "${config.home.homeDirectory}/Pictures"
      }/mpv-screenshots";

      #
      # video-align-y = -1;
    };
    bindings = {
      # h = "seek -0.01 keyframes";
      # j = "seek -30 keyframes";
      # k = "seek 30 keyframes";
      # l = "seek 0.01 keyframes";
      r = "cycle_values video-rotate 90 270 0"; # default subtitle loc
      R = "cycle_values video-rotate 270 90 0";
      "-" = "add video-zoom -0.076";
      "=" = "add video-zoom +0.076";
      RIGHT = "no-osd seek +1 keyframes";
      LEFT = "no-osd seek -1 keyframes";
      WHEEL_UP = "seek +1 keyframes";
      WHEEL_DOWN = "seek -1 keyframes";

      UP = "seek 30 keyframes";
      DOWN = "seek -30 keyframes";

      HOME = "seek 60 keyframes";
      END = "seek 60 keyframes";

      m = "cycle mute";

      x = "add sub-delay -0.1";
      X = "add sub-delay +0.1";
      c = "add sub-delay +0.1";

      "1" = "set current-window-scale 0.5";
      "2" = "set current-window-scale 1.0";
      "3" = "set current-window-scale 2.0";

      # "F6" = "cycle_values video-rotate 0";
      # "F7" = "cycle_values video-rotate 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90";
      # "F7" = "no-osd vf add rotate=1";
      # "F8" = "no-osd vf add rotate=2";

      "F9" = "add video-pan-x .05";
      "F10" = "add video-pan-y -.05";
      "F11" = "add video-pan-y .05";
      "F12" = "add video-pan-x -.05";
      # ";" = "set video-pan-x 0; set video-pan-y 0; set video-zoom 0";
    };
  };
  xdg.configFile."mpv/script-opts/mpv_thumbnail_script.conf" = {
    text = ''
      autogenerate=yes
      autogenerate_max_duration=0

      thumbnail_width=400
      thumbnail_height=225
      thumbnail_count=100

      min_delta=1
      max_delta=99999

      mpv_no_sub=yes
      mpv_hwdec=yes
      mpv_hr_seek=no

      hide_progress=no
    '';
  };

  # NOTE: https://github.com/NixOS/nixpkgs/issues/64344 <2023-05-08>
  # NOTE: https://github.com/nix-community/nur-combined/blob/master/repos/xddxdd/pkgs/uncategorized/svp/default.nix <2023-05-08>
  # (
  #   (nur.repos.xddxdd.svp.overrideAttrs (_: {
  #     libraries = [
  #       ffmpeg.bin
  #       glibc
  #       gnome.zenity
  #       libmediainfo
  #       libsForQt5.qtbase
  #       libsForQt5.qtdeclarative
  #       libsForQt5.qtscript
  #       libsForQt5.qtsvg
  #       libusb1
  #       lsof
  #       ocl-icd
  #       stdenv.cc.cc.lib
  #       vapoursynth
  #       xdg-utils
  #       xorg.libX11
  #       mpv
  #     ];
  #   }))
  #   .override {
  #     # nvidia_x11 =
  #     #   if extraConfig.nvidia
  #   }
  # )

  # profiles = {
  #   fullhd30 = {
  #     "profile-dsc" = "1080p @ 24-30fps";
  #     "profile-cond" = "((width ==1920 and height ==1080) and not p['video-frame-info/interlaced'] and p['estimated-vf-fps']<31)";
  #   };
  # };
}
