# https://github.com/EricKotato/sddm-slice
{
  lib,
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "sddm-theme-sugar-dark";
  version = "1.2";

  srcs = [
    (fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-dark";
      rev = "v${version}";
      hash = "sha256-C3qB9hFUeuT5+Dos2zFj5SyQegnghpoFV9wHvE9VoD8=";
    })
    # ../secrets/wallpapers
  ];
  sourceRoot = "source";

  # patches = [
  #   ./theme.conf.patch
  # ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes/sugar-dark
    cp -r * $out/share/sddm/themes/sugar-dark

    # cp ../wallpapers/Linux-Nixos-operating-system-minimalism-2175179-wallhere.jpg $out/share/sddm/themes/sugar-dark/Background.jpg

  '';

  meta = with lib; {
    description = "Sweeten the login experience for your users, your family and yourself.";
    homepage = "https://github.com/MarianArlt/sddm-sugar-dark";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
