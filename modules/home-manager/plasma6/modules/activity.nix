{
  lib,
  config,
  ...
}: let
  inherit (lib.attrsets) optionalAttrs;
  cfg = config.plasma6.activity;
in {
  options.plasma6.activity = {
    home = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      uuid = lib.mkOption {
        type = lib.types.str;
        default = "75367337-37cf-41b9-8efa-9f4ac834bc71";
      };
      icons = lib.mkOption {
        type = lib.types.str;
        default = "go-home-symbolic";
      };
    };
    work = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      uuid = lib.mkOption {
        type = lib.types.str;
        default = "7482e230-3dc6-43df-9579-5e07f8f5a067";
      };
      icons = lib.mkOption {
        type = lib.types.str;
        default = "folder-network-symbolic";
      };
    };
  };
  config = {
    programs.plasma.configFile."kactivitymanagerdrc" = builtins.foldl' lib.recursiveUpdate {} [
      (optionalAttrs cfg.home.enable {
        # "main".currentActivity = "${cfg.home.uuid}";
        "activities"."${cfg.home.uuid}".value = "Home";
        "activities-icons"."${cfg.home.uuid}".value = cfg.home.icons;
      })
      (optionalAttrs cfg.work.enable {
        "activities"."${cfg.work.uuid}".value = "Work";
        "activities-icons"."${cfg.work.uuid}".value = cfg.work.icons;
      })
    ];

    plasma6.windowRules = let
      wmclassMaker = classes: (builtins.concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
    in
      lib.lists.optionals cfg.home.enable [
        {
          enable = false;
          uuid = "d4f99020-4c41-454c-8d65-32fd39e2e8b1";
          description = "Make some browser only at home activity";
          Match = {
            "wmclass".value = wmclassMaker [
              # "firefox"
              # "[bB]rave-browser"
              # "chromium-browser"
            ];
            "wmclassmatch".value = 3;
          };
          Rule = {
            "activity".value = cfg.home.uuid;
            "activityrule".value = 2;
          };
        }
      ];
  };
}
