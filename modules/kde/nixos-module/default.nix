{
  pkgs,
  ...
}:
{
  imports = [
    ./ime.nix
    ./style.nix
    ./programs.nix
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

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      # NixOS 25.05 Updated
      plasma-browser-integration
      konsole
      # (lib.getBin qttools) # Expose qdbus in PATH
      ark
      elisa
      gwenview
      okular
      kate
      khelpcenter
      dolphin
      baloo-widgets # baloo information in Dolphin
      dolphin-plugins
      # spectacle
      ffmpegthumbs
      krdp
      xwaylandvideobridge # exposes Wayland windows to X11 screen capture
      discover
    ];
  };
}
