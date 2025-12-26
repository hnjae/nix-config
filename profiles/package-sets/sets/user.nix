{ lib, ... }:
pkgs:
(lib.flatten [
  # some basic utils
  pkgs.curl
  pkgs.dig
  pkgs.wget

  # ((import ./packages/ffmpeg.nix) pkgs)
  pkgs.ffmpeg-full
  (lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.convmv
  ])
  pkgs.tmux
  # NOTE: trashy is not usable because of following issue: https://github.com/Byron/trash-rs/issues/57 <2023-03-22>
  # pkgs.trashy # trash-cli alternative in rust
  pkgs.trash-cli

  ######################
  # some "modern" utils (https://github.com/ibraheemdev/modern-unix)
  ######################
  pkgs.cheat
  pkgs.navi
  pkgs.cht-sh
  pkgs.fzf
  pkgs.perl # fzf+zsh의 c-r 맵핑에서 사용.
  pkgs.ripgrep
  pkgs.ripgrep-all # ripgrep & PDF E-Books & Office documents & etc.
  pkgs.sd # 'modern' sed
  pkgs.delta # replace diff
  pkgs.vimv-rs # cyclic-renaming 지원, 엣지 케이스 대응 잘함.

  ######################
  # Shell
  ######################
  pkgs.zoxide
  pkgs.any-nix-shell

  ######################
  # Test 中
  ######################
  pkgs.mprocs # run multiple commands in parallel
  pkgs.fclones # rmlint 같은거
  pkgs.dos2unix # line break 변환기
  pkgs.speedtest-rs

  ######################
  # Qalc
  ######################
  (
    let
      appId = "qalculate";
      icon = "${pkgs.cosmic-icons}/share/icons/Cosmic/scalable/apps/accessories-calculator.svg";
    in
    [
      pkgs.libqalculate
      (pkgs.runCommandLocal appId { } ''
        mkdir -p "$out/share/icons/hicolor/scalable/apps/"

        cp --reflink=auto \
          "${icon}" \
          "$out/share/icons/hicolor/scalable/apps/${appId}.svg"
      '')

      (pkgs.makeDesktopItem {
        name = appId;
        desktopName = "Qalculate";
        categories = [
          "Utility"
          "Calculator"
        ];
        keywords = [
          "calculation"
          "arithmetic"
          "scientific"
          "financial"
        ];
        # exec = "${pkgs.alacritty}/bin/alacritty --class ${appId},${appId} --title Qalculate -e qalc %F";
        exec = ''wezterm start --class=${appId} -e qalc %F'';
        terminal = false;
        startupNotify = false;
        type = "Application";
        icon = appId; # icon = "accessories-calculator";
        # NOTE: icon=<full-path-to-icon> 식으로 지정하면, Gnome 에서는 잘 처리하나, KDE 에서는 처리하지 못함 <NixOS 25.05; KDE 6.3>.
      })
    ]
  )

  ######################
  # Fancy fetch 툴
  ######################
  pkgs.fastfetch # C, count nix pckage
  pkgs.cpufetch
  pkgs.ipfetch
  pkgs.onefetch # git
  (lib.lists.optional pkgs.stdenv.hostPlatform.isLinux pkgs.ramfetch)
  pkgs.pfetch-rs

  ######################
  # Misc
  ######################
  pkgs.ansible # 내 dotfiles repo 에서 사용
  pkgs.sysz # systemctl 커맨드를 fzf 로 래핑한 유틸
  pkgs.glow # markdown viewer in terminal
  pkgs.rmlint
  pkgs.unstable.yt-dlp
  pkgs.exiftool
  pkgs.mediainfo
  pkgs.btop
  (lib.hiPrio (
    pkgs.makeDesktopItem {
      name = "btop";
      desktopName = "btop++";
      genericName = "System Monitor";
      icon = "btop";
      exec = ''wezterm start --class=btop -e btop'';
      categories = [
        "System"
        "Monitor"
      ];
      keywords = [
        "system"
        "process"
        "task"
      ];
    }
  ))

  ######################
  # Test 중
  ######################
  pkgs.timg # image/video viewer in terminal
  pkgs.glow # markdown previewer
])
