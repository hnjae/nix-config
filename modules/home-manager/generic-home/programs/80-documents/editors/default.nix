{
  lib,
  config,
  pkgs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  imports = [
    ./neovim.nix
    ./vscodium.nix
    ./neovide.nix
    ./vscode.nix
  ];

  home.packages = let
    inherit (lib.lists) optionals;
  in (builtins.concatLists [
    # --
    (optionals genericHomeCfg.isDesktop [])
    # --
    (optionals genericHomeCfg.installTestApps (builtins.concatLists [
      # (with pkgsUnstable; [helix])
      (optionals (genericHomeCfg.isDesktop) (with pkgsUnstable; [
        # lapce
        # jetbrains.idea-community

        # emacs related
        # emacs29-pgtk
        # graphviz-nox

        zed-editor
      ]))
    ]))
  ]);

  services.flatpak.packages = lib.lists.optionals (pkgs.stdenv.isLinux
    && genericHomeCfg.isDesktop
    && genericHomeCfg.installTestApps) [
    # editors
    # "org.gnome.gitlab.cheywood.Buffer" # empty editor
    "io.gitlab.liferooter.TextPieces" # Developer's scratchpad
    # "dev.pulsar_edit.Pulsar" # editor, mit
  ];
}
