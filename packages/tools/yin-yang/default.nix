# https://github.com/oskarsh/Yin-Yang
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yin-yang
# NOTE: WIP <2024-06-11>
{
  lib,
  mkDerivation,
  fetchFromGitHub,
}:
mkDerivation rec {
  pname = "yin-yang";
  version = "3.4";

  src = fetchFromGitHub {
    owner = "oskarsh";
    repo = "Yin-Yang";
    rev = "v${version}";
    name = pname;
    sha256 = "";
  };

  buildInputs = [
  ];

  # nativeBuildInputs = [cmake];

  # sourceRoot = "${src.name}/src";

  meta = {
    description = "Auto Nightmode for KDE, Gnome, Budgie, VSCode, Atom and more";
    license = lib.licenses.mit;
    homepage = "https://github.com/oskarsh/Yin-Yang";
  };
}
