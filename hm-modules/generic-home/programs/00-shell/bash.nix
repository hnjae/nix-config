{
  config,
  pkgs,
  lib,
  ...
}: let
  common = (import ./share/common.nix) {inherit pkgs config lib;};
in {
  # home.packages = [
  #   pkgs.bashInteractive
  # ];

  programs.bash = {
    enable = true;

    # NOTE: profileExtra won't be sourced while using terminal like a konsole
    # ~/.profile
    profileExtra =
      builtins.concatStringsSep "\n" [common.envExtra common.profileExtra];

    # head of ~/.bashrc
    bashrcExtra = ''
      # ~/.profile 을 source 안하는 경우 대응
      [ -z "$__PROFILE_SOURCED" ] && [ -f "$HOME/.profile" ] && . "$HOME/.profile"

      set editing-mode vi
      set keymap vi-command
      # vi-insert or vi-command
    '';

    # in the middle of ~/.bashrc (after alias)
    initExtra = builtins.concatStringsSep "\n" [];

    # logoutExtra

    # let the terminal track the pwd
    enableCompletion = true;
    enableVteIntegration = false;

    historyFile = "${config.xdg.stateHome}/bash_history";
    inherit (common) historyIgnore;
    historyControl = ["erasedups" "ignoredups" "ignorespace"];
  };
}
