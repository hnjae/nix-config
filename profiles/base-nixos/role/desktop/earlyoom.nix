let
  /*
     HELP: https://github.com/rfjakob/earlyoom/blob/master/MANPAGE.md

     Run following to get process name: top, pstree, ps -e

    NOTE:
     > It is the first 15 bytes of the process name.

     `ps -e` 에서 출력되는 `comm` 를 그대로 사용하면 됨.
  */
  preferredProcesses = [
    "brave"
    "chrome" # google-chrome
    "chrome_crashpad"
    "chromium"
    "opera"
    "vivaldi-bin"

    "firefox"
    "firefox-bin"
    "zen"
    "librewolf"

    "\.librewolf-wrap"
    "\.brave-wrapped"

    # Electron 기반 앱들
    # "code"
    "Telegram"
    "Discord"
    "com.discordapp."
    "electron"

    "\.bat-wrapped"

    "ollama"
    "\.baloo_file-wra"
  ];
  avoidedProcesses = [
    # "1password"
    # "seaf-daemon"
    # "\.saefile-applet"

    "\.podman-wrapped"
    "conmon" # 컨테이너 모니터

    "Xwayland"
    "dconf-service"
    "systembus-notif" # 알림 브리지
    "xsettingsd"
    "\.gmenudbusmenup" # GTK 앱 메뉴 통합용.
    "\.kaccess-wrappe" # 접근성 도구
    "\.kactivitymanag"
    "\.kded6-wrapped"
    "\.ksecretd-wrapp"
    "\.kunifiedpush-d"
    "\.kwalletd6-wrap"
    "\.org_kde_powerd"
    "\.polkit-kde-aut"
    "\.xembedsniproxy" # 레거시 시스템 트레이 프록시

    "fcitx5-wayland-"
    "\.fcitx5-wrapped"

    "pipewire"
    "pipewire-pulse"
    "wireplumber"

    "xdg-dbus-proxy"
    "\.xdg-desktop-po"
    "\.xdg-permission"
    "\.xdg-document-p"
    "\.flatpak-sessio"

    "obexd" # bluetooth related
    "bluetoothd"
    "cupsd"

    "nix-daemon"
    "polkitd"
    "upowerd"
    "rtkit-daemon"
  ];
  ignoredProcesses = [
    # "systemd" # PID1 is already protected, oom_score == 0
    # "z_*" # zfs related thread: already protected, oom_score == 0
    # "btrfs-cleaner" # already protected, oom_score == 0
    # "btrfs-transaction" # already protected, oom_score == 0

    "systemd" # to protect user instances of systemd
    "systemd-journal"
    "systemd-logind"
    "systemd-machine"
    "systemd-oomd"
    "systemd-resolve"
    "systemd-udevd"

    ".tailscaled-wra"
    "NetworkManager"
    "ModemManager"
    "chronyd"
    "sshd"
    "dbus-daemon"

    "agetty"
    "sshd-session"

    "sddm"
    "sddm-helper"
    "\.kwin_wayland_w"
    "\.plasmashell-wr"
    "\.ksmserver-wrap" # session manager
    "\.startplasma-wa"
  ];
in
{ config, lib, ... }:
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    services.systembus-notify.enable = true;
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
      extraArgs = [
        "--ignore-root-user"
        "--prefer"
        "(^|/)(${builtins.concatStringsSep "|" preferredProcesses})$"
        "--avoid"
        "(^|/)(${builtins.concatStringsSep "|" avoidedProcesses})$"
        "--ignore"
        "(^|/)(${builtins.concatStringsSep "|" ignoredProcesses})$"
      ];
    };
  };
}
