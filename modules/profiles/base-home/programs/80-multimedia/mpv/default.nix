{
  pkgs,
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin isx86_64;
in
{
  default-app = {
    video = "mpv";
    audio = "mpv";
  };

  # NOTE: celluloid is very slow  <2024-12-15>
  services.flatpak.packages = [
    # "io.github.celluloid_player.Celluloid"
    # "info.smplayer.SMPlayer"
  ];

  # dconf.settings."io/github/celluloid_player/Celluloid" = {
  #   mpv-config-enable = true;
  #   mpv-config-file = "file:///${config.xdg.configHome}/mpv/mpv.conf";
  #   mpv-input-config-enable = true;
  #   mpv-input-config-file = "file:///${config.xdg.configHome}/mpv/input.conf";
  # };

  programs.mpv = {
    enable = baseHomeCfg.isDesktop;
    package = pkgs.mpv-unwrapped.wrapper {
      mpv = pkgs.mpv-unwrapped.override {
        alsaSupport = false;
        pulseSupport = false;
        jackaudioSupport = false;
        sdl2Support = false;
        vdpauSupport = false;
        x11Support = false;
        #
        cddaSupport = true; # default false; play CD
        sixelSupport = true; # default false
        vapoursynthSupport = isx86_64; # default false
      };
      youtubeSupport = true;
      scripts = builtins.concatLists [
        (lib.lists.optionals isLinux (
          with pkgs.mpvScripts;
          [
            mpris
          ]
        ))
        (with pkgs.mpvScripts; [
          # visualizer # visualize audio; CPU 자원 꽤 소모
          vr-reversal
          mpv-cheatsheet # type ? to see keyboard shortcuts
        ])
      ];
    };

    # defaultProfiles = ["gpu-hq"];
    /*
      NOTE:
      config = {
        x11-bypass-compositor = false;
      };

      Above config create following line. AND IT IS VALID MPV CONFIG
      `x11-bypass-compositor=%2%no` <2024-11-28>
    */
    config = {
      geometry = "1920x1080";
      # Video / Audio
      ao = if isDarwin then "coreaudio" else "pipewire";
      pipewire-volume-mode = lib.mkIf (isLinux) "global";
      replaygain = "track";

      # Scaling
      # HELP;
      # https://avisynthplus.readthedocs.io/en/latest/avisynthdoc/corefilters/resize.html
      # lanczos 는 ringing 현상이 좀 거슬리는듯.
      # scale = "ewa_lanczossharp";
      scale = "spline64";
      # sigmoid-upscaling = true; # enabled by defaults
      # dscale = "mitchell";
      # cscale = "mitchell"; # ignored by gpu-next?
      dscale = "spline64";
      cscale = "spline64"; # ignored by gpu-next?
      # correct-downscaling = true; # enabled by defaults
      sws-scaler = "spline";
      zimg-scaler = "spline36"; # default: lanczos

      #
      interpolation = true; # reduce stuttering

      # Screenshot
      screenshot-format = "png"; # default: jpg
      screenshot-tag-colorspace = true; # enabled by defaults
      screenshot-high-bit-depth = true; # enabled by defaults
      screenshot-template = "%F-%P-(%t%F)";
      screenshot-png-compression = 9;
      screenshot-webp-lossless = true;
      screenshot-webp-quality = 100;
      screenshot-webp-compression = 6; # best compression
      screenshot-jxl-distance = 0; # lossless
      screenshot-jxl-effort = 9; # best compression
      screenshot-directory = "${config.xdg.userDirs.pictures}/mpv-screenshots";

      # do not disable compositor
      ytdl-format = "bestvideo+bestaudio";

      # osd
      osd-fractions = true; # show osd times with fractions of seconds
      term-osd-bar = true; # default: false
      osd-bar = false; # no osd bar when skipping time
      osd-duration = 800; # default 1000
      osd-blur = 0.1; # default 0
      osd-level = 1; # osd shows up on user interaction
      # osd-font-size = 60; # default 55
      # osd-font = "monospace";

      #   # sub
      #   sub-blur = 0.11;
      #   sub-font-size = 40; # default 55
      #   sub-ass-line-spacing = 25; # srt 자막에도 적용됨.
      #   sub-margin-x = 120; # default 25
      #   sub-ass-override = true; # 위 옵션적용
      #   sub-font = "KoreanCNMM";
      #   sub-border-size = 2.3; # default 3
      #
      #   # sub-filter-sdh="yes" # remove deaf or hard-of-hearing subtitle
      #   # sub-filter-sdh-harder="yes"

      # default values:
      video-sync = "display-resample";
      # framedrop = "vo";
      # dither-depth = "auto";

      #
      # temporal-dither = true;
    };

    #
    #   # testing options
    #   error-diffusion = "burkes";
    #
    #   #
    #   vo = "gpu-next";
    #   af = "lavfi=[loudnorm]";
    #   gpu-api = "auto";
    #   vulkan-async-compute = true; # ! isNvidia
    #   # hwdec = "auto-copy";
    #   hwdec = "auto";
    #   # hwdec-codecs = "all";
    #   hr-seek = "default";
    #
    #   #
    #   osc = true;
    #   # osd
    #
    #   # behavior
    #   keep-open = true;
    #
    # };

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

    profiles = {
      fast2 = {
        correct-downscaling = false;
        # scale = "nearest";
        # dscale = "nearest";
        # cscale = "nearest";
        # sws-scaler = "fast-bilinear";
        scale = "bicubic_fast";
        dscale = "bicubic_fast";
        cscale = "bicubic_fast";
        sws-scaler = "fast-bilinear";
        zimg-scaler = "bicubic";
        vo = "gpu-next";
        hwdec = "vaapi";
        framedrop = "decoder";
        sws-fast = true;
      };

      audio = {
        replaygain = "track";
        audio-display = false;
      };
    };

    scriptOpts = {
      # xdg.configFile."mpv/script-opts/mpv_thumbnail_script.conf"
      "mpv_thumbnail_script" = {
        autogenerate = true;
        autogenerate_max_duration = 0;
        thumbnail_width = 400;
        thumbnail_height = 225;
        thumbnail_count = 100;
        min_delta = 1;
        max_delta = 99999;
        mpv_no_sub = true;
        mpv_hwdec = true;
        mpv_hr_seek = false;
        hide_progress = false;
      };
    };
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
