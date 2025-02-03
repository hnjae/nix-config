{
  config,
  pkgs,
  lib,
  ...
}:
{
  # zsh, bash, fish 공통사용
  # .zshenv 에서 source 함
  home.sessionVariables = lib.attrsets.mergeAttrsList [
    {
      # PAGER = "less -i";
    }
    (lib.attrsets.optionalAttrs pkgs.config.allowUnfree {
      NIXPKGS_ALLOW_UNFREE = 1;
    })
    (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      # to use other locale in gui and use en_IE in shell.
      # NOTE: sessionVariables were being ignored by KDE's value (NixOS 22.11)
      LC_TIME = "en_IE.UTF-8";
    })
    {
      EDITOR = lib.mkDefault "vi";
    }
  ];

  # NOTE: 적용 안됨. __HM_ZSH_SESS_VARS_SOURCED=1 임에도 EDITOR 가 설정되지 않는다. 디깅 해야할 듯.
  programs.zsh.sessionVariables = {
    inherit (config.home.sessionVariables) EDITOR;
  };

  # .zshenv 말미
  programs.zsh.envExtra = lib.concatLines [
    # ''
    #   EDITOR="${config.home.sessionVariables.EDITOR}"
    # ''
    (lib.strings.optionalString pkgs.stdenv.isLinux ''
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
