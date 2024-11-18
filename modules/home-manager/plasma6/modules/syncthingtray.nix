{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  cfg = config.plasma6.syncthingtray;
in {
  options.plasma6.syncthingtray = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
    };
    systemd = {
      isSystemd = lib.mkOption {
        type = types.bool;
        default = true;
      };
      isSystemUnit = lib.mkOption {
        type = types.bool;
        default = true;
      };
      unitName = lib.mkOption {
        type = types.str;
        default = "syncthing.service";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.syncthingtray.override {
        kioPluginSupport = false;
        plasmoidSupport = false;
        systemdSupport = false;
      })
    ];

    plasma6.windowRules = [
      {
        uuid = "2d0fa865-3761-483f-9892-123e20dcd87c";
        description = "syncthingtray";
        Match = {
          "wmclass".value = "syncthingtray";
          "wmclassmatch".value = 2; # substring match
        };
        Rule = {
          "activity".value = "00000000-0000-0000-0000-000000000000";
          "activityrule".value = 2; # force
          "above".value = true;
          "aboverule".value = 2; # force
        };
      }
    ];

    xdg.configFile."autostart/syncthingtray.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Syncthing Tray
        GenericName=Syncthing Tray
        Comment=Tray application for Syncthing
        Exec=syncthingtray --wait
        Icon=syncthingtray
        Terminal=false
        Type=Application
        Categories=Network

        [Desktop Action open-webui]
        Name=Open web UI
        Exec=syncthingtray --webui
      '';
    };

    programs.plasma.resetFilesExclude = ["syncthingtray.ini"];

    # NOTE: connections 정보를 매번 지워버리게 됨. <2024-06-13>
    # plasma-manager에서 파일 처리 과정 문제로 추정.
    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/syncthingtray.ini";
        mode = "600";
        type = "file";
      }
    ];

    # programs.plasma.configFile."syncthingtray.ini" = {
    #   qt = {
    #     customfont.value = false;
    #     customicontheme.value = false;
    #     customlocale.value = false;
    #     font.value = "Sans Serif,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    #     custompalette.value = false;
    #     customstylesheet.value = false;
    #     customwidgetstyle.value = false;
    #     local.value = "en_US";
    #   };
    #   startup = {
    #     #
    #     syncthingAutostart.value = false;
    #     #
    #     syncthingPath.value = "";
    #     syncthingArgs.value = "";
    #     showLauncherButton.value = false;
    #     considerLauncherForReconnect.value = false;
    #     useLibSyncthing.value = false;
    #     "tools\\Process\\args".value = "";
    #     "tools\\Process\\path".value = "";
    #     "tools\\Process\\autostart".value = false;
    #     # systemd
    #     showButton.value = cfg.systemd.isSystemd;
    #     stopServiceOnMetered = cfg.systemd.isSystemd;
    #     considerForReconnect.value = cfg.systemd.isSystemd;
    #     syncthingUnit.value = cfg.systemd.unitName;
    #     systemUnit.value = cfg.systemd.isSystemUnit;
    #   };
    #   tray = {
    #     #
    #     notifyOnDisconnect.value = true;
    #     notifyOnErrors.value = true;
    #     notifyOnLauncherErrors.value = true;
    #     notifyOnNewDeviceConnects.value = true;
    #     notifyOnNewDirectoryShared.value = true;
    #     # synccomplete notify
    #     notifyOnLocalSyncComplete.value = false;
    #     notifyOnRemoteSyncComplete.value = false;
    #     #
    #     dbusNotifications.value = true;
    #     ignoreInavailabilityAfterStart.value = 15;
    #     #
    #     windowType.value = 1; # normal window
    #     tabPos.value = 1; # tab@bottom
    #     showTabTexts.value = true;
    #     preferIconsFromTheme.value = true;
    #     #
    #     showSyncthingNotifications.value = true;
    #   };
    #   webview = {
    #     customCommand.value = "";
    #     disabled.value = true;
    #     keepRunning.value = false;
    #     mode.value = 1; # use default browser
    #     zoomFactor.value = 1;
    #   };
    # };
  };
}
