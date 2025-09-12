{
  python3,
  unrar,
}:
python3.pkgs.buildPythonApplication {
  preferLocalBuild = true;

  pname = "archive-previewer";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = with python3.pkgs; [ flit-core ];
  dependencies = with python3.pkgs; [
    rarfile
    tabulate
    python-magic
  ];

  propagateBuildInputs = [
    unrar
  ];
}
