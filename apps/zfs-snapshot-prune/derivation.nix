{
  installShellFiles,
  python3,
}:
python3.pkgs.buildPythonApplication rec {
  preferLocalBuild = true;

  pname = "zfs-snapshot-prune";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = with python3.pkgs; [ flit-core ];
  dependencies = with python3.pkgs; [
    rich
    typer-slim
    isodate
    tabulate
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in {ba,fi,z}sh; do
      $out/bin/${pname} --show-completion "$shell" > "${pname}.$shell"
    done

    installShellCompletion ${pname}.{ba,fi,z}sh
  '';

  meta = {
    mainProgram = "zfs-snapshot-prune";
  };
}
