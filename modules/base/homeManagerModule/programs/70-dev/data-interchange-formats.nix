{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = builtins.concatLists [
      (with pkgsUnstable; [
        # toml
        taplo # lsp for toml written in rust

        # yaml
        yaml-language-server
        yamlfmt
      ])
      [
        (pkgs.runCommandLocal "vscode-json-language-server" { } ''
          mkdir -p $out/bin
          ln -s "${pkgsUnstable.vscode-langservers-extracted}/bin/vscode-json-language-server" "$out/bin/vscode-json-language-server"
        '')
      ]
    ];
  };
}
