{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  description = "Update flatpak packages";
  documentation = ["man:flatpak-update(1)"];
  # flatpakPath = "/run/current-system/sw/bin/flatpak";
  flatpakPath = "${pkgs.flatpak}/bin/flatpak";
  serviceName = "flatpak-update";
  # TODO: systemd.network.wait-online <2024-01-10>
  waitOnlineService = lib.lists.optional config.networking.networkmanager.enable "NetworkManager-wait-online.service";

  cfg = config.services.${serviceName};
in {
  options.services.${serviceName} = {
    enable = mkEnableOption (lib.mDoc "");

    onCalendar = mkOption {
      type = types.str;
      default = "Mon, Fri";
      description = lib.mdDoc "";
    };
  };
  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    systemd.services."${serviceName}" = {
      inherit documentation;
      inherit description;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = builtins.concatStringsSep " " [
          flatpakPath
          "update"
          "--assumeyes"
          "--noninteractive"
        ];
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        Nice = 19;
        # User = config.users.users.main.name;
        # Group = config.users.users.main.group;
        # WorkingDirectory = config.users.users.main.home;
      };

      # NOTE: network-online.target 은 multi-user.tager 의 dependency 임 <2024-01-10>
      # requires = ["network-online.target"] ++ waitOnlineService;
      # after = ["network-online.target"] ++ waitOnlineService;

      # NOTE: 시스템 부팅할때 실행시,
      # Warning: Treating remote fetch error as non-fatal since ..
      # 하며 오류를 뿜음.
      # 자꾸 실패하니 관련 있어보이는 모듈 전부 넣자. <2024-01-11>
      # NOTE: 이래도 안되면, 그냥 sleep 5분 걸어버려. <2024-01-11>
      after =
        [
          # 다음은 유저 서비스임
          # "xdg-desktop-portal.service"
          # "flatpak-portal.service"
          # "flatpak-session-helper.service"
          # "pipewire.service"

          "polkit.service"
          "NetworkManager.service"
          "dbus-broker.service"

          # "accounts-daemon.service"
        ]
        ++ ["network-online.target"]
        ++ waitOnlineService;
    };

    systemd.timers."${serviceName}" = {
      inherit documentation;
      inherit description;

      timerConfig = {
        OnCalendar = cfg.onCalendar;
        AccuracySec = "1d";
        Persistent = true;
      };

      # NOTE: https://www.freedesktop.org/software/systemd/man/systemd.unit.html
      # NOTE: https://www.freedesktop.org/software/systemd/man/bootup.html
      wantedBy = ["timers.target"];
    };
  };
}
