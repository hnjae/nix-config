{ pkgsUnstable, ... }:
{
  home.packages = builtins.concatLists [
    (with pkgsUnstable; [
      just # make alike
    ])
  ];

  home.shellAliases = {
    j = "just";
    je = "just --edit";
    # je = "just-edit";
  };

  # programs.zsh.initContent = ''
  #   just-edit () {
  #     $EDITOR "$(git rev-parse --show-toplevel || echo .)/justfile"
  #   }
  # '';
}
