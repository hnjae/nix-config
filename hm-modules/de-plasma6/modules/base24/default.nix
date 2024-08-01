{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.plasma6.base24;
in {
  options.plasma6.base24 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    theme = lib.mkOption {
      type = lib.types.enum ["green" "blue" "purple" "default"];
      defualt = "green";
    };
  };
  config = lib.mkIf config.plasma6.base24.enable {
    xdg.dataFile."color-schemes/base24-green.colors".source = config.scheme {
      templateRepo = inputs.base24-kdeplasma;
      target = "default-green";
    };
    xdg.dataFile."color-schemes/base24-blue.colors".source = config.scheme {
      templateRepo = inputs.base24-kdeplasma;
      target = "default-blue";
    };
    xdg.dataFile."color-schemes/base24-purple.colors".source = config.scheme {
      templateRepo = inputs.base24-kdeplasma;
      target = "default-purple";
    };
    xdg.dataFile."color-schemes/base24.colors".source = config.scheme {
      templateRepo = inputs.base24-kdeplasma;
      target = "default";
    };

    programs.plasma.workspace = {
      theme = "default";
      colorScheme = "base24-${cfg.theme}";
      lookAndFeel = "org.kde.breeze.desktop";
    };
  };
}
