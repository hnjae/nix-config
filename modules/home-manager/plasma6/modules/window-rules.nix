{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;
  windowRuleType = lib.types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      uuid = mkOption {type = types.str;};
      description = mkOption {type = types.str;};
      Match = mkOption {type = types.attrs;};
      Rule = mkOption {type = types.attrs;};
    };
  };
  cfg = config.plasma6.windowRules;
in {
  options.plasma6.windowRules = lib.mkOption {
    type = lib.types.listOf windowRuleType;
    default = [];
    description = "";
    apply = rules: (
      builtins.filter (rule: rule.enable) rules
    );
  };

  config = {
    programs.plasma.configFile."kwinrulesrc" = let
      windowRules = cfg;
      uuids = map (x: x.uuid) windowRules;
      rules = builtins.listToAttrs (map (item: {
          name = item.uuid;
          value =
            item.Match
            // item.Rule
            // {
              "Description".value = item.description;
            };
        })
        windowRules);

      numRules = builtins.length uuids;
    in (lib.attrsets.optionalAttrs (numRules > 0) (rules
      // {
        "General" = {
          "count".value = numRules;
          "rules".value = builtins.concatStringsSep "," uuids;
        };
      }));
  };
}
