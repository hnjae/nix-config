{
  pkgs,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  # config = lib.mkIf (genericHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
  #   home.packages = [
  #     # pkgs.firefox-bin
  #     pkgs.firefox
  #   ];
  #
  #   stateful.cowNodes = [
  #     {
  #       path = "${config.home.homeDirectory}/.mozilla";
  #       mode = "755";
  #       type = "dir";
  #     }
  #   ];
  # };

  imports = [
    ./betterfox.nix
    ./my-overrides.nix
    ./sidebery.nix
  ];

  programs.firefox = {
    enable = genericHomeCfg.isDesktop && pkgs.stdenv.isLinux;
    package = pkgs.firefox;
    nativeMessagingHosts = [];
    policies = {};
    profiles.home = {
      # extensions = with pkgs; [
      #   nur.repos.rycee.firefox-addons.darkreader
      #   nur.repos.rycee.firefox-addons.vimium-c
      #   nur.repos.rycee.firefox-addons.leechblock-ng
      #
      #   # https://www.privacytools.io/privacy-browser-addons
      #   nur.repos.rycee.firefox-addons.ublock-origin
      #   nur.repos.rycee.firefox-addons.localcdn
      #   nur.repos.rycee.firefox-addons.clearurls
      # ];
    };
  };
}
