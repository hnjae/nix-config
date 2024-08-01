{pkgs, ...}: {
  environment.defaultPackages = with pkgs; [
    # THEMEs
    # phinger-cursors # not-my-taste <2023-?>
    bibata-cursors
    apple-cursor # hidpi
    graphite-cursors
    google-cursor

    icon-theme-we10x
    kde-theme-we10xos

    # fluent-gtk-theme
    kde-theme-fluent
    icon-theme-fluent

    # 너무 짝퉁 같음.
    # kde-theme-whitesur
    # icon-theme-whitesur

    lightly-boehs
    # libsForQt5.lightly
    # lightly-qt

    # whitesur-gtk-theme
    # wallpapers-whitesur
    # kde-theme-monterey

    # gtk
    adw-gtk3
    # gradience

    #
    # graphite-kde-theme
    # graphite-gtk-theme

    # papirus-icon-theme
    # flat-remix-icon-theme
    # moka-icon-theme
  ];
}
