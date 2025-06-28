{
  python3,
}:
python3.pkgs.buildPythonApplication {
  preferLocalBuild = true;

  pname = "nix-gc-sysgen";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = with python3.pkgs; [ flit-core ];
}
