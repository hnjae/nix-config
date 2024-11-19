{
  config,
  inputs,
  lib,
  ...
}: let
  # type = lib.types.enum ["green" "blue" "purple" "default"];
  theme = "green";
in {
  config = lib.mkIf config.generic-home.base24.enable {
    # TODO: 패키지화 <2024-08-19>
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
      colorScheme = "base24-${theme}";
      lookAndFeel = "org.kde.breeze.desktop";
    };
  };
}
