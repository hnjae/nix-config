{
  config,
  pkgs,
  lib,
  ...
}: {
  # zsh, bash, fish 공통사용
  home.sessionVariables = lib.attrsets.mergeAttrsList [
    {
      # PAGER = "less -i";
    }
    (lib.attrsets.optionalAttrs pkgs.config.allowUnfree {
      NIXPKGS_ALLOW_UNFREE = 1;
    })
    (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      LC_TIME = "en_IE.UTF-8";
    })
    {
      EDITOR = lib.mkDefault "vi";
    }
  ];

  # .zshenv 말미
  programs.zsh.envExtra = lib.concatLines [
    ''
      EDITOR="${config.home.sessionVariables.EDITOR}"
    ''
    (lib.strings.optionalString pkgs.stdenv.isLinux ''
      # to use other locale in gui and use en_IE in shell.
      # NOTE: sessionVariables were being ignored by KDE's value (NixOS 22.11)
      LC_TIME="${config.home.sessionVariables.LC_TIME}"
    '')
  ];

  programs.bash.profileExtra = lib.concatLines [
    ''
      EDITOR="${config.home.sessionVariables.EDITOR}"
    ''
    (lib.strings.optionalString pkgs.stdenv.isLinux ''
      # to use other locale in gui and use en_IE in shell.
      # NOTE: sessionVariables were being ignored by KDE's value (NixOS 22.11)
      LC_TIME="${config.home.sessionVariables.LC_TIME}"
    '')
  ];

  programs.fish.shellInit = lib.concatLines [
    ''
      set -x EDITOR "${config.home.sessionVariables.EDITOR}"
    ''
    (lib.strings.optionalString pkgs.stdenv.isLinux ''
      set -x LC_TIME "${config.home.sessionVariables.LC_TIME}"
    '')
  ];
}
