{pkgs, ...}: {
  environment.defaultPackages = with pkgs; [
    # Esseentials
    xsettingsd
    # ddcutil # do i need this?

    # libraries
    libsForQt5.qt5.qtimageformats
    libsForQt5.kimageformats
    # libsForQt5.qtpbfimageplugin
    ffmpegthumbnailer
    libsForQt5.ffmpegthumbs
    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.kdegraphics-mobipocket
    libsForQt5.kio-extras
    libsForQt5.kdenetwork-filesharing

    # ??
    libsForQt5.syntax-highlighting
    # libsForQt5.syndication
    # libsForQt5.sonnet
    # libsForQt5.solid

    # hardware info in info center
    glxinfo
    vulkan-tools
    wayland-utils
    xorg.xdpyinfo
    aha
    libsForQt5.qt5.qttools
    qt6.qttools
  ];

  # for hardware info in info center
  services.fwupd.enable = true;

  # allow kde to config desktop
  # for gtk app in plasma-gui
  # programs.dconf.enable = false;
  programs.dconf.enable = true;
}
