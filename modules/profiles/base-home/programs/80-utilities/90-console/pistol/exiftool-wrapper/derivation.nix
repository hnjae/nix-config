{
  python3,
  exiftool,
}:
python3.pkgs.buildPythonApplication {
  preferLocalBuild = true;

  pname = "exiftool-wrapper";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = with python3.pkgs; [ flit-core ];
  dependencies = with python3.pkgs; [
    tabulate
  ];

  propagateBuildInputs = [
    exiftool
  ];
}
