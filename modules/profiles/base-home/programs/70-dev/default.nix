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
    ./dbus.nix
    ./go.nix
    ./json-alikes.nix
    ./jvm.nix
    ./lua.nix
    ./markdown-alikes.nix
    ./nix.nix
    ./nodejs.nix
    ./python.nix
    ./ruby.nix
    ./rust.nix
    ./shell.nix
  ];

  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = builtins.concatLists [
      (with pkgs; [
        gcc
        gnumake
        cmake
      ])
      (with pkgsUnstable; [
        # editorconfig
        editorconfig-checker
        pkgsUnstable.harper # grammer checker for developers
      ])
    ];
  };
}
