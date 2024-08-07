{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  imports = [
    ./brave.nix
    ./google-chrome.nix
    ./firefox.nix
    # ./vivaldi.nix
    # ./microsoft-edge.nix
    # ./opera.nix
  ];

  config = lib.mkIf (genericHomeCfg.isDesktop) {
    home.packages = builtins.concatLists [
      [
        # floorp
        # vieb
        # vimb
      ]
      (lib.lists.optionals (pkgs.stdenv.isLinux)
        (with pkgs; [
          nyxt
          luakit
          qutebrowser
        ]))
    ];
  };
}
