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
  imports = [
    ./data-interchange-formats.nix
    ./db.nix
    ./git
    ./go.nix
    ./jvm.nix
    ./lua.nix
    ./markup-language.nix
    ./nix-tools.nix
    ./nix.nix
    ./nodejs
    ./pueue.nix
    ./python.nix
    ./ruby.nix
    ./rust.nix
    ./shell.nix
    ./web-dev
  ];

  config = lib.mkIf baseHomeCfg.installDevPackages {
    home.packages = builtins.concatLists [
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
      (with pkgsUnstable; [
        # editorconfig
        editorconfig-checker

        harper # grammer checker for developers
        hyperfine # command-line benchmarking tool
      ])
    ];

    services.flatpak.packages = [
      "me.iepure.devtoolbox" # https://flathub.org/apps/me.iepure.devtoolbox

      "com.jgraph.drawio.desktop" # apache2
      "org.gaphor.Gaphor" # UML modeling, apache 2

      "com.github.marhkb.Pods" # connects to podman
    ];
  };
}
