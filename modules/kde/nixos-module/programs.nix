{ pkgs, ... }:
{
  users.users.hnjae.packages = with pkgs; [
    kdePackages.skanpage
  ];

  environment.systemPackages = with pkgs; [
    unrar
    konsave
    kdePackages.qtimageformats # webp, ...
    kdePackages.kimageformats # avif, jxl, heif, ...
    kdePackages.ksystemlog

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
