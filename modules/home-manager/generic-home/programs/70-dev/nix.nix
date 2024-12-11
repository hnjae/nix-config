{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      # rnix-lsp -- dead 2024-03-16

      # lsp
      nixd
      nil

      # lint
      nixpkgs-lint
      statix
      deadnix

      # formatter
      alejandra

      # others
      compose2nix
    ];
  };
}
