{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    basedpyright
    ty
    (pkgs.python3.withPackages (
      python-pkgs: with python-pkgs; [
        ipython
        ruff
        pytest
        pytest-cov
        pytest-mock
      ]
    ))
  ];
}
