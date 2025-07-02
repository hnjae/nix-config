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
      ];

      default-app.image = "org.kde.gwenview";
    }
  ];
}
