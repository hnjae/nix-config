{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    basedpyright
    (pkgs.python3.withPackages (
      python-pkgs: with python-pkgs; [
        ipython
        ruff
      ]
    ))
  ];
}
