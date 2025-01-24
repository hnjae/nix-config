# HELP: https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-mkShell-attributes
# { pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/06278c77b5d162e62df170fec307e83f1812d94b.tar.gz") {} }:
{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  env = {
    RUST_BACKTRACE = "1";
  };

  packages = with pkgs; [
    (python3.withPackages (
      ps:
      (builtins.concatLists [
        (with ps; [
          ipython
          jedi
          jedi-language-server
          python-lsp-server
          mypy
          isort
          pynvim
          black
        ])
      ])
    ))
  ];

  shellHook = ''
    echo "blabla"
  '';
}
