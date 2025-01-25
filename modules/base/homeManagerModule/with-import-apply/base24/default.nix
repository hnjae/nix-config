{ inputs, ... }:
{
  lib,
  config,
  ...
}:
let
  cfg = config.base-home.base24;
  inherit (lib) mkOption types;
  inherit (lib.attrsets) mergeAttrsList;
  inherit (builtins) getAttr;

  # NOTE: comment out 된 scheme 은 내 취향 아님. <2024-01-15>
  # ashes = "ashes";
  # phd = "phd";
  # tomorrow-night = "tomorrow-night";
  # windows-95 = "windows-95";

  schemes = mergeAttrsList [
    (builtins.mapAttrs
      # https://github.com/tinted-theming/base24/?tab=readme-ov-file#scheme-repositories
      (
        _: colorVariant:
        (builtins.mapAttrs (
          _: schemeName: "${inputs.base16-schemes}/base24/${schemeName}.yaml"
        ) colorVariant)
      )
      {
        dracula = {
          dark = "dracula";
        };
        framer = {
          dark = "framer";
        };
        github = {
          light = "github";
        };
        one = {
          dark = "one-dark";
          black = "one-black";
          light = "one-light";
        };
      }
    )
    {
      dimidium = {
        dark = ./schemes/dimidium.yaml;
      };
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
in
{
  options.base-home.base24 = {
    # enable = lib.mkEnableOption "Enable base24 colorscheme";
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    variant = mkOption {
      type = types.enum [
        "light"
        "dark"
        "darker"
      ];
      default = "light";
    };
    scheme = mkOption {
      type = types.enum (builtins.attrNames schemes);
      default = "gruvbox";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.BASE16_THEME = cfg.scheme;
    scheme = getAttr (cfg.variant) (getAttr cfg.scheme schemes);
  };
}
