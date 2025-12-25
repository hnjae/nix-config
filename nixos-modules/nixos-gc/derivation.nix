{
  lib,
  python3,
}:
python3.pkgs.buildPythonApplication {
  preferLocalBuild = true;

  pname = "nixos-gc";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = with python3.pkgs; [ flit-core ];
  meta = {
    platforms = lib.platforms.linux;
    mainProgram = "nixos-gc";
  };
}
