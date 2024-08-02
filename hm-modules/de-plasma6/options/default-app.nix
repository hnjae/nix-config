{...}: {
  default-app = {
    image = "org.kde.gwenview";
    fileManager = "org.kde.dolphin";
    fromApps = [
      "org.kde.konsole"
      # "org.kde.dolphin" dolphin 은 xdg-portal 안쓰는듯??? <NixOS 24.05>
    ];
    mime = {
      "application/pdf" = "org.kde.okular";
      "application/epub+zip" = "org.kde.okular";
      "application/x-mobipocket-ebook" = "org.kde.okular";
    };
    archive = "org.kde.ark";
  };
}
