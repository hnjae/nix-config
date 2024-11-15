# NOTE: use following instead <2024-01-29>
# https://github.com/GermanBread/declarative-flatpak
{
  lib,
  config,
  ...
}: {
  imports = [
    ./flatpak-update.nix
    ./flatpak-uninstall-unused.nix
  ];
}
