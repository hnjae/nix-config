{...}: {
  imports = [
    ./packages
    ./display-manager.nix
    ./ime.nix
    ./xdg-portal.nix
  ];

  services.xserver.enable = true;
  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
    # notoPackage = pkgs.noto-fonts-lgc-plus;
  };
}
