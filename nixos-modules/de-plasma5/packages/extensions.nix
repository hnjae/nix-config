{
  pkgs,
  inputs,
  ...
}: {
  environment.defaultPackages = with pkgs; [
    # Apps
    # libsForQt5.bismuth
    libsForQt5.applet-window-buttons
    # libsForQt5.krunner-symbols

    # not usable
    # libsForQt5.plasma-applet-virtual-desktop-bar
    # libsForQt5.plasma-applet-caffeine-plus

    #
    plasma-applet-active-window-control

    #
    inputs.kwin-scripts.packages.${stdenv.system}.virtual-desktops-only-on-primary
    kwin-script-always-open-on
  ];
}
