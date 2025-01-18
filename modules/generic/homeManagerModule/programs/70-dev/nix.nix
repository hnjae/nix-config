{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
  aliases = {
    se = "sops edit";
  };
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      sops # edit secrets

      # lsp
      # rnix-lsp -- dead 2024-03-16
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

    home.shellAliases = aliases;

    xdg.configFile."zsh-abbr/user-abbreviations".text = (
      lib.concatLines (
        lib.mapAttrsToList
        (
          key: value: ''abbr "${key}"="${value}"''
        )
        aliases
      )
    );
  };
}
