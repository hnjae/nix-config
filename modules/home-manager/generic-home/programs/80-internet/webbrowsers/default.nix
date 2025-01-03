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
    # ./firefox
    # ./vivaldi.nix
    # ./microsoft-edge.nix
  ];

  config = lib.mkIf (genericHomeCfg.isDesktop) {
    default-app.browser = "io.github.zen_browser.zen";

    services.flatpak.packages = [
      "io.github.zen_browser.zen"
    ];

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

          # firefox-bin
          firefox-devedition-bin
          librewolf
        ]))
    ];

    stateful.nodes = [
      {
        path = "${config.home.homeDirectory}/.librewolf";
        mode = "700";
        type = "dir";
      }
      {
        path = "${config.home.homeDirectory}/.mozilla";
        mode = "700";
        type = "dir";
      }
    ];
  };
}
