{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = builtins.concatLists [
      (with pkgsUnstable; [
        # toml
        taplo # lsp for toml written in rust

        # editorconfig
        editorconfig-checker

        # yaml
        yaml-language-server
        yamlfmt
      ])
      [
        (pkgs.runCommand "vscode-json-language-server" {} ''
          mkdir -p $out/bin
          ln -s "${pkgsUnstable.vscode-langservers-extracted}/bin/vscode-json-language-server" "$out/bin/vscode-json-language-server"
        '')
      ]
    ];
  };
}
