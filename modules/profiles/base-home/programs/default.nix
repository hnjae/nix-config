/*
  NOTE:
    카테고리는 <https://wiki.archlinux.org/title/List_of_applications> 에서 따왔다.
*/
{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./00-shell
    ./10-console-tools
    ./70-dev
    ./70-dev-tools
    ./80-documents
    ./80-internet
    ./80-multimedia
    ./80-others
    ./80-security
    ./80-utilities
  ];

  home.packages = builtins.concatLists [
    (lib.lists.optional (
      inputs.py-utils ? packages
    ) inputs.py-utils.packages.${pkgs.stdenv.system}.default)
  ];
}
