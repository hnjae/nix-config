{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  preferLocalBuild = true;

  pname = "uuid7";
  version = "0.1.1"; # checked 2025-05-21

  src = fetchFromGitHub {
    owner = "akrabat";
    repo = "uuid7";
    rev = version;
    hash = "sha256-5+t9hCUxJHDcspNDu73vBYr5HTUITHOWbM+175++qEg=";
  };

  vendorHash = "sha256-miGMbrnmdBiRr6Giyiv0eEs3l8yGNTBr4UXc202y8NA=";

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/com.akrabat.uuid7 $out/bin/uuid7
  '';

  meta = {
    description = "UUID v7 command line tool";
    homepage = "https://github.com/akrabat/uuid7";
    license = lib.licenses.mit;
    mainProgram = "uuid7";
  };
}
