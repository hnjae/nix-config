{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = with pkgsUnstable; [
      # lsp
      # rnix-lsp -- dead 2024-03-16
      nixd
      nil

      # lint
      nixpkgs-lint
      statix
      deadnix

      # formatter
      nixfmt-rfc-style
    ];
  };
}
