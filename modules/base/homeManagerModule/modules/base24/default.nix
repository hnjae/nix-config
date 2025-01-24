{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.base-home.base24;
  inherit (lib) mkOption types;
  inherit (lib.attrsets) mergeAttrsList;
  inherit (builtins) getAttr;

  # base16 = mergeAttrsList [
  #   (builtins.mapAttrs (_: val: "${inputs.base16-schemes}/base16/${val}.yaml")
  #     {
  #       # NOTE: comment out 된 scheme 은 내 취향 아님. <2024-01-15>
  #       # ashes = "ashes";
  #       # phd = "phd";
  #       # tomorrow-night = "tomorrow-night";
  #       # windows-95 = "windows-95";
  #       classic-dark = "classic-dark";
  #       default-dark = "default-dark";
  #       harmonic16-dark = "harmonic16-dark";
  #       ia-dark = "ia-dark";
  #       kanagawa = "kanagawa";
  #       macintosh = "macintosh";
  #       material-darker = "material-darker";
  #       tokyo-night-dark = "tokyo-night-dark";
  #       tokyodark = "tokyodark";
  #       windows-10 = "windows-10";
  #     })
  # ];

  schemes = mergeAttrsList [
    (builtins.mapAttrs
      # https://github.com/tinted-theming/base24/?tab=readme-ov-file#scheme-repositories
      (_: colorVariant: (builtins.mapAttrs
        (_: schemeName: "${inputs.base16-schemes}/base24/${schemeName}.yaml")
        colorVariant)) {
        dracula = {dark = "dracula";};
        framer = {dark = "framer";};
        github = {light = "github";};
        one = {
          dark = "one-dark";
          black = "one-black";
          light = "one-light";
        };
      })
    {
      dimidium = {dark = ./schemes/dimidium.yaml;};
      adwaita = {
        dark = ./schemes/adwaita-dark.yaml;
        darker = ./schemes/adwaita-darker.yaml;
        light = ./schemes/adwaita-light.yaml;
      };
      gruvbox = {
        dark = ./schemes/gruvbox-dark.yaml;
        light = ./schemes/gruvbox-light.yaml;
      };
      kanagawa = {
        dark = ./schemes/kanagawa-dragon.yaml;
        light = ./schemes/kanagawa-lotus.yaml;
      };
    }
  ];
in {
  options.base-home.base24 = {
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

  config = lib.mkIf cfg.enable {
    home.sessionVariables.BASE16_THEME = cfg.scheme;
    scheme = getAttr (
      if cfg.darkMode
      then "dark"
      else "light"
    ) (getAttr cfg.scheme schemes);
  };
}
