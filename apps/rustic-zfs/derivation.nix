{
  lib,
  stdenv,
  makeWrapper,
  rustic,
  rclone,
  jq,
  coreutils,
  util-linux,
  pwgen,
}:
stdenv.mkDerivation rec {
  preferLocalBuild = true;
  pname = "rustic-zfs";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    rustic
    rclone
    jq
    coreutils # date
    util-linux # findmnt
    pwgen
  ];

  installPhase = ''
    mkdir -p $out/bin

    cp rustic-zfs $out/bin/rustic-zfs
    chmod +x $out/bin/rustic-zfs

    wrapProgram $out/bin/rustic-zfs \
      --prefix PATH : ${lib.makeBinPath buildInputs}
  '';

  meta = with lib; {
    description = "ZFS dataset backup tool using rustic";
    mainProgram = "rustic-zfs";
    platforms = platforms.unix;
  };
}
