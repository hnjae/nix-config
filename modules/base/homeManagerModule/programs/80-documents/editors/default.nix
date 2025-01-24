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
    ./vscodium.nix
    ./neovide.nix
    ./vscode.nix
  ];

  home.packages =
    let
      inherit (lib.lists) optionals;
    in
    (builtins.concatLists [
      # --
      (optionals baseHomeCfg.isDesktop [
        # lapce
        # jetbrains.idea-community

        # emacs related
        # emacs29-pgtk
        # graphviz-nox

        pkgsUnstable.zed-editor
      ])
    ]);

  services.flatpak.packages = lib.lists.optionals (pkgs.stdenv.isLinux && baseHomeCfg.isDesktop) [
    # editors
    # "org.gnome.gitlab.cheywood.Buffer" # empty editor
    "io.gitlab.liferooter.TextPieces" # Developer's scratchpad
    # "dev.pulsar_edit.Pulsar" # editor, mit
  ];
}
