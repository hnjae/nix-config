{ pkgs, ... }:
{
  home-manager.sharedModules = [
    {
      services.flatpak.packages = [
        "org.kde.ark"
        # "org.kde.dolphin" # lacks mtp/sftp support <2025-07-05>
        # "org.kde.konsole"
        "org.kde.gwenview" # it supports HEIC
        "org.kde.okular" # flathub's build lacks rar support
        "org.kde.kontact"
        "org.kde.kwrite"
      ];

      default-app.image = "org.kde.gwenview";
      default-app.fromApps = [ "org.kde.dolphin" ];
    }
  ];

  environment.systemPackages = with pkgs; [
    unrar
    kdePackages.qtimageformats # webp, ...
    kdePackages.kimageformats # avif, jxl, heif, ...

    # pkgs.kara # pager alternative KDE widget

    # kdePackages.dolphin
    # kdePackages.dolphin-plugins
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    # NixOS 25.05 Updated

    plasma-browser-integration
    # konsole # dolphin requires konosle to open terminal
    # (lib.getBin qttools) # Expose qdbus in PATH
    ark
    elisa
    gwenview
    okular
    kate
    khelpcenter
    # dolphin
    baloo-widgets # baloo information in Dolphin
    # dolphin-plugins
    # spectacle
    # ffmpegthumbs
    krdp
    xwaylandvideobridge # exposes Wayland windows to X11 screen capture
    discover
  ];
}
