{pkgs, ...}: {
  environment.defaultPackages = builtins.concatLists [
    (with pkgs; [
      # widgets
      compact-pager
      application-title-bar
    ])
    # (with pkgsUnstable; [
    # widgets
    # application-title-bar
    # ])
  ];
  /*
  ----
  # NOTE

  * libsForQt5.bismuth
    : dead [2024-06-16](https://github.com/Bismuth-Forge/bismuth)
      Use [polonium](https://github.com/zeroxoneafour/polonium)

  ## Not Usable & plamsa5

  * libsForQt5.plasma-applet-virtual-desktop-bar
  * libsForQt5.plasma-applet-caffeine-plus

  ## plasma5
  * plasma-applet-active-window-control
  * libsForQt5.applet-window-buttons
  * libsForQt5.krunner-symbols
  * inputs.kwin-scripts.packages.${stdenv.system}.virtual-desktops-only-on-primary
  * kwin-script-always-open-on
  ----
  */
}
