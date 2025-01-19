# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  PYTHONPATH = "${pkgs.kitty}/lib/kitty";

  packages = with pkgs; [
    (python311.withPackages (ps: (with ps; [
      ipython
      jedi
      jedi-language-server
      python-lsp-server
      mypy
      isort
      pynvim
      black
    ])))
  ];
}
