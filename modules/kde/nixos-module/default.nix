{
  pkgs,
  ...
}:
{
  imports = [
    ./ime.nix
    ./programs.nix
    ./style.nix
  ];

  config = {
    services.xserver.enable = false;
    services.xserver.excludePackages = [ pkgs.xterm ];
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    security.pam.services.login.kwallet.enable = true;

    environment.systemPackages = [
      # X 서버를 disable 했으므로, 필요한 패키지를 따로 설치.
      pkgs.xorg.xprop
    ];
    environment.sessionVariables = {
      GTK_USE_PORTAL = "1"; # gtk-3 app 에서 적용
    };
  };
}
