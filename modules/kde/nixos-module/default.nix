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
    services.xserver.enable = true;
    services.xserver.excludePackages = [ pkgs.xterm ];

    security.pam.services.login.kwallet.enable = true;

    services.displayManager.sddm.enable = true;

    services.desktopManager.plasma6 = {
      enable = true;
    };

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
