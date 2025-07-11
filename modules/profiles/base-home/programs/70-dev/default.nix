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
    # ./jvm.nix
    ./lua.nix
    ./markdown-alikes.nix
    ./nix.nix
    ./nodejs.nix
    ./python.nix
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
        editorconfig-checker
        harper # grammar checker for developers
        vale
      ])
    ];
  };
}
