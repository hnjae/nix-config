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

    pkgsUnstable.buildah

    pkgsUnstable.universal-ctags
    pkgsUnstable.hyperfine # command-line benchmarking tool
    pkgsUnstable.gh # github cli
    pkgsUnstable.gh-copilot

    pkgsUnstable.awscli2

    pkgsUnstable.mani # <https://github.com/alajmo/mani>
    pkgsUnstable.glow

    # pkgsUnstable.chezmoi
    pkgsUnstable.dotbot
    (lib.lists.optional pkgs.stdenv.hostPlatform.isLinux pkgsUnstable.distrobox)
  ];

  services.flatpak.packages = [
    "me.iepure.devtoolbox" # https://flathub.org/apps/me.iepure.devtoolbox

    "com.jgraph.drawio.desktop" # apache2
    "org.gaphor.Gaphor" # UML modeling, apache 2

    "com.github.marhkb.Pods" # connects to podman
  ];
}
