{
  lib,
  config,
  pkgs,
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

  services.flatpak.packages =
    lib.lists.optionals (pkgs.stdenv.hostPlatform.isLinux && baseHomeCfg.isDesktop)
      [
        # editors
        # "org.gnome.gitlab.cheywood.Buffer" # empty editor
        # "dev.pulsar_edit.Pulsar" # editor, mit
        "io.gitlab.liferooter.TextPieces" # Developer's scratchpad
      ];
}
