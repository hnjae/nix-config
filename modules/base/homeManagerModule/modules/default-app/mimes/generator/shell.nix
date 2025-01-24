{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs; [
    (python3.withPackages (ps: (builtins.concatLists [
      (with ps; [
        ipython
        python-lsp-server
        mypy
        ruff
        isort
        black
        #
        pydantic
        defusedxml
      ])
    ])))
  ];

  # shellHook = ''
  #   alias foo=nvim
  # '';
}
