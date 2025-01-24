/*
NOTE:
  /run/current-system/sw/share/mime/packages/freedesktop.org.xml
  https://wiki.archlinux.org/title/default_applications

 TODO: document formats
 e.g.
 "application/vnd.oasis.opendocument.spreadsheet"

  TODO:
  x-scheme-handler/vscode 같은 x-scheme-handler/* 처리 고민.

# TODO: flatpak permission-set 이 시간을 엄청 잡아먹으니, systemd-unit 으로
# 만들고, activation-unit으로 만들어 실행하기.

그러면 변형값이 생겼을때만 실행될것으로 기대됨. <2024-07-15>

성공적으로 종료되었을때, 실행중이라는 속성을 부여해야할 것같다.
*/
{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.default-app;
  genericToMimes = mimes: app: (
    if (app == null)
    then {}
    else (lib.genAttrs mimes (_: app))
  );
in {
  options.default-app = {
    enable = lib.mkEnableOption ''
      Set default app of various mime
    '';

    resetPrevious = mkOption {
      type = types.bool;
      default = true;
    };

    # setPortal = mkOption {
    #   type =types.bool;
    #   default = true;
    #   description = ''
    #     for system which use `xdg.portal.xdgOpenUsePortal`
    #   '';
    # };

    fromApps = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["com.logseq.Logseq" "org.kde.konsole"];
    };

    browser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "";
    };

    fileManager = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "org.kde.dolphin";
      description = ''
        "inode/directory"
      '';
    };

    mime = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Can override other default app configured.
      '';
      example = {
        "application/pdf" = "org.kde.okular";
        "image/x-xcf" = "org.gimp.GIMP";
      };
    };

    text = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "mpv";
      apply = genericToMimes (import ./mimes/text.nix);
    };

    video = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "mpv";
      apply = genericToMimes (import ./mimes/video.nix);
    };

    audio = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "mpv";
      apply = genericToMimes (import ./mimes/audio.nix);
    };

    image = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "org.kde.gwenview";
      apply = genericToMimes (import ./mimes/image.nix);
    };

    archive = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "org.kde.ark";
      apply = genericToMimes (import ./mimes/archive.nix);
    };
  };

  config = lib.mkIf cfg.enable (let
    mimeMerged = lib.attrsets.mergeAttrsList [
      cfg.text
      cfg.archive
      cfg.image
      cfg.audio
      cfg.video
      (lib.attrsets.optionalAttrs (cfg.browser != null) ((genericToMimes [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ])
        cfg.browser))
      cfg.mime
    ];
  in {
    # dolphin 같은 류가 `GTK_USE_PORTAL=1` ,`NIXOS_XDG_OPEN_USE_PORTAL=1` 가
    # 설정되어 있어도, mimeapps.list 를 따름. <NixOS 24.05>
    xdg.mimeApps = {
      enable = true;
      defaultApplications = lib.attrsets.mergeAttrsList [
        (builtins.mapAttrs (_: app: ["${app}.desktop"]) mimeMerged)
        (lib.attrsets.optionalAttrs (cfg.fileManager != null) {
          "inode/directory" = "${cfg.fileManager}.desktop";
        })
      ];
    };

    systemd.user.services."flatpak-set-default-app" = let
      mimeData = builtins.concatLists (
        map (fromApp: (lib.mapAttrsToList
          (mime: defaultApp: {inherit mime defaultApp fromApp;})
          mimeMerged))
        cfg.fromApps
      );

      flatpakSetDefaultApp = pkgs.writeShellApplication {
        name = "flatpak-set-default-app";
        runtimeInputs = with pkgs; [flatpak coreutils gawk];
        text = lib.concatLines ([
            (lib.strings.optionalString (cfg.resetPrevious) ''
              # reset previous
              for mime in $(flatpak permissions desktop-used-apps | awk '{print $2}' | uniq); do
                flatpak permission-remove desktop-used-apps "$mime"
              done
            '')
          ]
          ++ (map (x: (builtins.concatStringsSep " " [
              "flatpak"
              "permission-set"
              "desktop-used-apps"
              ''"${x.mime}"''
              ''"${x.fromApp}"''
              ''"${x.defaultApp}"''
              "3"
              "3"
            ]))
            mimeData));
      };
    in {
      Unit = {After = ["multi-user.target"];};
      Service = {
        Type = "oneshot";
        ExecStart = "${flatpakSetDefaultApp}/bin/flatpak-set-default-app";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        RemainAfterExit = true;
        # ExecStart = "${pkgs.dash}/bin/dash -c ':'";
        # ExecReload = "${flatpakSetDefaultApp}/bin/flatpak-set-default-app";
      };
    };

    home.activation = {
      # flatpak-set-default-app = lib.mk.dag.entryAfter ["reloadSystemd"] ''
      #   export PATH=${lib.makeBinPath (with pkgs; [systemd])}:$PATH
      #
      #   $DRY_RUN_CMD systemctl is-system-running -q && systemctl --user start flatpak-set-default-app
      # '';

      # setDefaultBrowser = lib.mkIf (cfg.browser != null) (
      #   lib.hm.dag.entryAfter ["writeBoundary"] ''
      #     run --silence "${pkgs.xdg-utils}/bin/xdg-settings" set default-web-browser ${cfg.browser}.desktop
      #   ''
      # );
    };
  });
}
