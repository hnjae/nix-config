{
  home-manager.sharedModules = [
    {
      services.flatpak.packages = [
        "org.kde.ark"
        "org.kde.dolphin"
        "org.kde.gwenview" # it supports HEIC
        "org.kde.okular" # flathub's build lacks rar support
        # "org.kde.konsole"
        "org.kde.kontact"
        "org.kde.kwrite"
      ];

      default-app.image = "org.kde.gwenview";
      default-app.fromApps = [ "org.kde.dolphin" ];
    }
  ];
}
