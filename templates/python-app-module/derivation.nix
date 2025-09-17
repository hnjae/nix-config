{
  installShellFiles,
  lib,
  pkgs,
  python3,
}:
python3.pkgs.buildPythonApplication rec {
  preferLocalBuild = true;

  pname = "zfs-prune";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = with python3.pkgs; [ flit-core ];
  dependencies = with python3.pkgs; [
    rich
    (
      (typer.override {
        rich = null;
        shellingham = null;
      }).overridePythonAttrs
      (_: {
        pname = "typer-slim";
        env.TIANGOLO_BUILD_PACKAGE = "typer-slim";
        dontCheckRuntimeDeps = true;
        doCheck = false;
      })
    )
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in {ba,fi,z}sh; do
      $out/bin/${pname} --show-completion "$shell" > "${pname}.$shell"
    done

    installShellCompletion ${pname}.{ba,fi,z}sh
  '';
}
