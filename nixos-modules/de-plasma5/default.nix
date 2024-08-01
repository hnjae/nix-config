{...}: {
  imports = [
    ./fcitx-wayland.nix
    ./display-manager.nix
    ./packages
    ./xdg-portal-flatpak.nix
    # ./expose-fhs-resources.nix
  ];

  services.xserver.desktopManager.plasma5 = {
    # TODO: fix app autostarts before plasma-wayland initialize <2023-05-01>
    # https://github.com/NixOS/nixpkgs/issues/225605
    runUsingSystemd = true;
    enable = false;
    phononBackend = "vlc";
    useQtScaling = true;
  };
}
