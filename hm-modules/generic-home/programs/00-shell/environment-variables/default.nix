{
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
}
