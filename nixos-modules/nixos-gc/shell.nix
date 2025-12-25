{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    basedpyright
    ty
    ruff
    (pkgs.python3.withPackages (
      python-pkgs: with python-pkgs; [
        ipython
        pytest
        pytest-cov
        pytest-mock
      ]
    ))
  ];
}
