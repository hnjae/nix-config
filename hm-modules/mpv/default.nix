{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (pkgs.stdenv) hostPlatform;
  inherit (osConfig.networking) hostName;

  isFHD = builtins.elem hostName [ "isis" ];
in
{
  programs.mpv = {
    enable = true;
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
        vapoursynthSupport = hostPlatform.isx86_64; # default false
      };
      youtubeSupport = true;
      scripts = lib.flatten [
        (lib.lists.optional hostPlatform.isLinux pkgs.mpvScripts.mpris)
        (with pkgs.mpvScripts; [
          visualizer # visualize audio; CPU 자원 꽤 소모
          vr-reversal
          mpv-cheatsheet # type ? to see keyboard shortcuts
          thumbfast
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
      # initial window size
      geometry = if isFHD then "1344x756" else "2720x1530";

      # Audio
      ao = if hostPlatform.isDarwin then "coreaudio" else "pipewire";
      pipewire-volume-mode = lib.mkIf hostPlatform.isLinux "global";
      replaygain = "track";
      replaygain-fallback = "-6";
      #   af = "loudnorm";

      # Video
      # https://github.com/mpv-player/mpv/wiki/GPU-Next-vs-GPU
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "auto-copy"; # to use video-filters
      vd-lavc-framedrop = "nonref";
      vd-lavc-show-all = true;
      vd-lavc-skiploopfilter = "none";
      libplacebo-opts = builtins.concatStringsSep "," [
        "deinterlace_algo=bwdif" # default yadif
      ]; # requires vo=gpu-next

      # Scaling
      /*
        NOTE:
          - https://iamscum.wordpress.com/guides/videoplayback-guide/mpv-conf/#scaler
          - https://avisynthplus.readthedocs.io/en/latest/avisynthdoc/corefilters/resize.html
      */
      # lanczos 는 ringing 현상이 좀 거슬리는듯.
      scale = "ewa_lanczos4sharpest";
      cscale = "ewa_lanczos4sharpest"; # ignored by gpu-next?
      dscale = "ewa_robidouxsharp";
      sigmoid-upscaling = true;
      target-colorspace-hint = true; # requires gpu-next

      # SW Scaler (requires `--vf=scale`)
      sws-scaler = "spline";
      sws-allow-zimg = true;
      zimg-scaler = "spline36";
      zimg-scaler-chroma = "spline36";
      zimg-fast = false;

      deband = true;
      deband-iterations = 3; # higher = more cpu usage

      # NOTE: fullscreen 일때 framedrop 심하게 발생.
      # To reduce stuttering,
      # interpolation = true;
      # interpolation-preserve = true; # Preserve  the  previous  frames'  interpolated results (only works on vo=gpu-next)
      # video-sync = "display-tempo";

      # audio-buffer = 1; # default 0.2 s

      # Screenshot
      screenshot-format = "png"; # default: jpg
      screenshot-template = "%F-%P-(%t%F)";
      screenshot-directory = "${config.xdg.userDirs.pictures}/mpv-screenshots";
      screenshot-tag-colorspace = true; # enabled by defaults
      screenshot-jpeg-quality = 95; # default 90
      screenshot-high-bit-depth = true; # enabled by defaults
      screenshot-jxl-distance = 0; # lossless
      screenshot-jxl-effort = 9; # best compression
      screenshot-png-compression = 9;
      screenshot-webp-compression = 6; # best compression
      screenshot-webp-lossless = true;
      screenshot-webp-quality = 100;

      ytdl-format = builtins.concatStringsSep "/" (
        let
          heightLimit = toString (if isFHD then 1200 else 1440);
          vidLimit = ''best*[vcodec!=none][height>=1080][height<=${heightLimit}][fps<=60]'';
        in
        [
          "${vidLimit}[acodec!=none]"
          "${vidLimit}[acodec=none]+bestaudio"
          "bestvideo+bestaudio"
          "best"
        ]
      );

      # osd
      osd-bar = false; # no osd bar when skipping time
      osd-bar-outline-size = 1; # default 0.5
      osd-blur = 0.1; # default 0
      osd-bold = true;
      osd-duration = 800; # default 1000
      osd-font = "Monospace"; # default: Sans serif
      osd-font-size = 35; # default 30
      osd-fractions = true; # show osd times with fractions of seconds
      osd-level = 1; # osd shows up on user interaction
      term-osd-bar = true; # default: false

      # sub
      sub-blur = 0.1;
      sub-bold = true;
      sub-outline-size = 1.65; # default: 1.65
      #   sub-font-size = 40; # default 55
      #   sub-ass-line-spacing = 25; # srt 자막에도 적용됨.
      #   sub-margin-x = 120; # default 25
      #   sub-ass-override = true; # 위 옵션적용
      #   sub-font = "KoreanCNMM";
      #   sub-border-size = 2.3; # default 3
      #
      #   # sub-filter-sdh="yes" # remove deaf or hard-of-hearing subtitle
      #   # sub-filter-sdh-harder="yes"

      # Disc Devices
      cdda-paranoia = 2;
      cdda-speed = 1;
      dvd-speed = 1;
    };

    profiles = {
      sw-scale = {
        hwdec = "auto-copy";
        vf = builtins.concatStringsSep "," [
          "scale"
        ];
      };

      deinterlace = {
        deinterlace = false;
        hwdec = "auto-copy";
        vf = builtins.concatStringsSep "," [
          "bwdif"
        ];
      };

      deinterlace-slow = {
        deinterlace = false;
        hwdec = "auto-copy";
        vf = builtins.concatStringsSep "," [
          "nnedi"
        ];
      };

      deblock = {
        # deband = false;
        scale-blur = "0.9"; # sharpen
        hwdec = "auto-copy";
        vf = builtins.concatStringsSep "," [
          "deblock=filter=strong"
          # "scale"
          # "unsharp"
        ];
      };

      denoise = {
        hwdec = "auto-copy";
        vf = builtins.concatStringsSep "," [
          "hqdn3d"
          # "nlmeans"

        ];
      };

      denoise-slow = {
        hwdec = "auto-copy";
        vf = builtins.concatStringsSep "," [
          "bm3d"
        ];
      };

      medium = {
        vd-lavc-skiploopfilter = "default";

        scale = "ewa_lanczos";
        dscale = "hermite";
        cscale = "ewa_lanczos";
        sws-scaler = "bicubic";
        zimg-scaler = "spline16";
        zimg-scaler-chroma = "spline16";
      };

      very-fast = {
        vd-lavc-skiploopfilter = "default";
        hwdec = "auto";
        # vd-lavc-framedrop = "nonkey"; # 프레임 드롭: 키프레임 외 모든 프레임

        correct-downscaling = false;
        scale = "bilinear";
        dscale = "bilinear";
        cscale = "bilinear";

        sws-allow-zimg = false;
        sws-scaler = "fast-bilinear";
        sws-fast = true;
        zimg-scaler = "bilinear";
        zimg-scaler-chroma = "bilinear";
        zimg-fast = true;

        deband = false;
        deband-iterations = 1;
      };

      anime = {
        zimg-scaler = "lanczos";
      };

      audio = {
        replaygain = "track";
      };
      audio-normalize = {
        af = "loudnorm";
      };

      hdr = {
        # WIP
        vo = "gpu-next";
        gpu-api = "vulkan";
        target-colorspace-hint = true; # requires gpu-next
        target-contrast = "auto"; # Max contrast ratio of your supported device, usually ~1000 for IPS, ~3000-5000 for VA and inf for OLED)
      };
    };

    bindings = {
      # https://github.com/mpv-player/mpv/blob/master/etc/input.conf
      # NEW
      r = "cycle_values video-rotate 90 180 270 0"; # default subtitle loc
      R = "cycle_values video-rotate 270 180 90 0";
      "-" = "add video-zoom -0.076";
      "=" = "add video-zoom +0.076";

      # SEEK
      RIGHT = "no-osd seek +1 keyframes";
      LEFT = "no-osd seek -1 keyframes";
      WHEEL_UP = "seek +1 keyframes"; # default: change volume
      WHEEL_DOWN = "seek -1 keyframes"; # default: change volume
      UP = "seek 30 keyframes";
      DOWN = "seek -30 keyframes";
      HOME = "seek 60 keyframes"; # NEW
      END = "seek 60 keyframes"; # NEW

      # Toggle things
      m = "cycle mute"; # default
      b = "cycle deband"; # default
      d = "cycle deinterlace"; # default
      k = "vf toggle deblock"; # NEW

      # remap bindings for colemak-dh layout (default: z Z x)
      x = "add sub-delay -0.1";
      X = "add sub-delay +0.1";
      c = "add sub-delay +0.1";

      # Zoom presets (default: contrast, brightness, gamma, saturation adjust)
      "1" = "set current-window-scale 0.5";
      "2" = "set current-window-scale 1.0";
      "3" = "set current-window-scale 2.0";

      # Function keys
      "F5" = "add video-rotate -1"; # NEW
      "F6" = "set video-rotate 0"; # NEW
      "F7" = "add video-rotate 1"; # NEW

      "F9" = "add video-pan-x .05"; # NEW
      "F10" = "add video-pan-y -.05"; # NEW
      "F11" = "add video-pan-y .05"; # NEW
      "F12" = "add video-pan-x -.05"; # NEW
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
