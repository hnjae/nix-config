/*
  README:
    - `sync-default-apps` 라는 스크립트 제공.
    - 완전 declarative 하게 선언하는건 시간 낭비로 보임. home-manager activation 시점에 실행해야할텐데, 매부팅마다 이것을 할 수는 없음.

  NOTE:
    /run/current-system/sw/share/mime/packages/freedesktop.org.xml
    https://wiki.archlinux.org/title/default_applications

   TODO: document formats
   e.g.
   "application/vnd.oasis.opendocument.spreadsheet"

    TODO:
    x-scheme-handler/vscode 같은 x-scheme-handler/* 처리 고민.
*/
{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.default-app;
  genericToMimes = mimes: app: (if (app == null) then { } else (lib.genAttrs mimes (_: app)));
in
{
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
      default = [ ];
      example = [
        "com.logseq.Logseq"
        "org.kde.konsole"
      ];
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
      default = { };
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

  config = lib.mkIf cfg.enable (
    let
      mimeMerged = lib.attrsets.mergeAttrsList [
        cfg.text
        cfg.archive
        cfg.image
        cfg.audio
        cfg.video
        (lib.attrsets.optionalAttrs (cfg.browser != null) (
          (genericToMimes [
            "text/html"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
          ])
            cfg.browser
        ))
        cfg.mime
      ];
    in
    {
      # dolphin 같은 류가 `GTK_USE_PORTAL=1` ,`NIXOS_XDG_OPEN_USE_PORTAL=1` 가
      # 설정되어 있어도, mimeapps.list 를 따름. <NixOS 24.05>
      xdg.mimeApps = {
        enable = lib.mkForce false;
        defaultApplications = lib.attrsets.mergeAttrsList [
          (lib.attrsets.optionalAttrs (cfg.fileManager != null) {
            "inode/directory" = "${cfg.fileManager}.desktop";
          })
          (builtins.mapAttrs (_: app: [ "${app}.desktop" ]) mimeMerged)
        ];
      };

      home.packages = [
        (
          let
            mimeData = builtins.concatLists (
              map (
                fromApp:
                (lib.mapAttrsToList (mime: defaultApp: {
                  inherit mime defaultApp fromApp;
                }) mimeMerged)
              ) cfg.fromApps
            );
            setDefaultFlatpakAppCmd = lib.concatLines (
              map (
                x:
                (builtins.concatStringsSep " " [
                  "flatpak"
                  "permission-set"
                  "desktop-used-apps"
                  "'${x.mime}'"
                  "'${x.fromApp}'"
                  "'${x.defaultApp}'"
                  "3"
                  "3"
                ])
              ) mimeData
            );
            setDefaultXdgAppCmd = lib.concatLines (
              map (
                x:
                (builtins.concatStringsSep " " [
                  "xdg-mime"
                  "default"
                  "'${x.defaultApp}.desktop'"
                  "'${x.mime}'"
                ])
              ) mimeData
            );
          in
          (pkgs.writeShellApplication {
            name = "sync-default-apps";
            runtimeInputs = with pkgs; [
              flatpak
              coreutils
              gawk
            ];
            text = ''
              set -euo pipefail

              reset=false

              usage() {
                echo "Usage: $(basename -- "''$0") [-r]"
                exit 1
              }

              while getopts ":rh" opt; do
              case ''${opt} in
                h)
                  usage
                  ;;
                r)
                  reset=true
                  ;;
                \?)
                  echo "Invalid Option: -$OPTARG" >&2
                  usage
                  ;;
                :)
                  echo "Invalid Option: -$OPTARG requires an argument" >&2
                  usage
                  ;;
                esac
              done
              shift $((OPTIND - 1))

              if [ "''$#" -ne 0 ]; then
                echo "Error: No positional argument is required" >&2
                usage
              fi

              reset_previous() {
                for mime in ''$(flatpak permissions desktop-used-apps | awk '{print $2}' | uniq); do
                  echo "Resetting flatpak desktop-used-apps for mime: ''$mime" >&2
                  flatpak permission-remove desktop-used-apps "''$mime"
                done
              }

              configure_flatpak() {
                ${setDefaultFlatpakAppCmd}
              }

              configure_xdg() {
                ${setDefaultXdgAppCmd}
              }


              main() {
                if "$reset"; then
                  echo "Reset previous flatpak desktop-used-apps" >&2
                  reset_previous
                fi

                configure_flatpak
                configure_xdg
              }

              main
            '';
          })
        )
      ];
    }
  );
}
