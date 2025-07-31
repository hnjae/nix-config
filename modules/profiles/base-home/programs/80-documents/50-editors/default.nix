{
  lib,
  config,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  imports = [
    ./neovim.nix
    ./vscode.nix
  ];

  home.packages =
    let
      inherit (lib.lists) optionals;
    in
    (builtins.concatLists [
      # --
      (optionals baseHomeCfg.isDesktop [
        pkgsUnstable.jetbrains.idea-community

        # lapce
        # emacs related
        # emacs29-pgtk
        # graphviz-nox

        pkgsUnstable.zed-editor
        # pkgsUnstable.code-cursor
      ])
    ]);

  services.flatpak.packages =
    lib.lists.optionals (pkgs.stdenv.hostPlatform.isLinux && baseHomeCfg.isDesktop)
      [
        # editors
        # "org.gnome.gitlab.cheywood.Buffer" # empty editor
        # "dev.pulsar_edit.Pulsar" # editor, mit
        "io.gitlab.liferooter.TextPieces" # Developer's scratchpad
      ];
}
