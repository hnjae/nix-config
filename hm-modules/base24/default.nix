{
  config,
  inputs,
  lib,
  ...
}: let
  # https://github.com/tinted-theming/schemes/tree/spec-0.11/base16
  # https://github.com/tinted-theming/schemes
  # https://tinted-theming.github.io/base16-gallery/
  inherit (lib.attrsets) mergeAttrsList;

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
  cfg = config.base24;
in {
  options.base24 = let
    inherit (lib) mkOption types;
  in {
    scheme = mkOption {
      default = "gruvbox";
      type = types.str;
    };
    variant = mkOption {
      default = "dark";
      type = types.str;
      description = "dark or light or darker (if supported)";
    };
  };

  config = let
    inherit (builtins) getAttr;
  in {scheme = getAttr cfg.variant (getAttr cfg.scheme schemes);};
}
