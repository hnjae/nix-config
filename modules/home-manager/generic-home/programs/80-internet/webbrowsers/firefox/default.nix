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
    ./firefox-ui-fix.nix
  ];

  programs.firefox = {
    enable = genericHomeCfg.isDesktop && pkgs.stdenv.isLinux;
    package = pkgs.firefox;
    nativeMessagingHosts = [];
    policies = {};
    profiles.home = {};
  };
}
