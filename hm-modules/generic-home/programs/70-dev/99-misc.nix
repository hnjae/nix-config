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
        chromedriver
        openssl

        #
        patchelfStable
      ])
      ++ (with pkgsUnstable; [
        rust-bin.stable.latest.default
        hyperfine # command-line benchmarking tool
      ]);
  };
}
