{
  lib,
  config,
  ...
}: let
  cfg = config."generic-home";
  inherit (lib) mkOption types;
in {
  options.generic-home.base24 = {
    enable = lib.mkEnableOption "Enable base24 colorscheme";
    darkMode = mkOption {
      type = types.bool;
      default = true;
    };
    scheme = mkOption {
      type = types.str;
      default = "gruvbox";
    };
  };

  config = lib.mkIf cfg.base24.enable {
    home.sessionVariables.BASE16_THEME = cfg.base24.scheme;
    base24 = {
      inherit (cfg.base24) scheme;
      variant =
        if (cfg.base24.darkMode)
        then "dark"
        else "light";
    };
  };
}
