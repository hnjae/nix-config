{
  pkgs,
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages =
      (with pkgs; [
        gcc
        gnumake
        cmake
        universal-ctags

        # man pages
        man-pages
        man-pages-posix

        #
        openssl

        #
        patchelfStable
      ])
      ++ (with pkgsUnstable; [
        harper # grammer checker for developers
        rust-bin.stable.latest.default
        hyperfine # command-line benchmarking tool
      ]);

    services.flatpak.packages = lib.mkIf genericHomeCfg.isDesktop [
      "me.iepure.devtoolbox" # https://flathub.org/apps/me.iepure.devtoolbox

      "com.jgraph.drawio.desktop" # apache2
      "org.gaphor.Gaphor" # UML modeling, apache 2

      "com.github.marhkb.Pods" # connects to podman
    ];
  };
}
