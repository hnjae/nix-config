{
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
{
  imports = [
    ./50-db.nix
    ./50-nix-tools.nix
    ./50-web-dev.nix
  ];

  home.packages = lib.flatten [
    pkgs.openssl
    pkgs.patchelfStable

    pkgsUnstable.universal-ctags
    pkgsUnstable.hyperfine # command-line benchmarking tool
    pkgsUnstable.gh # github cli
    pkgsUnstable.github-copilot-cli

    (lib.lists.optional pkgs.stdenv.isLinux pkgsUnstable.distrobox)
  ];

  services.flatpak.packages = [
    "me.iepure.devtoolbox" # https://flathub.org/apps/me.iepure.devtoolbox

    "com.jgraph.drawio.desktop" # apache2
    "org.gaphor.Gaphor" # UML modeling, apache 2

    "com.github.marhkb.Pods" # connects to podman
  ];
}
