{pkgs, ...}: {
  home.packages = builtins.concatLists [
    (with pkgs.libsForQt5; [kdevelop])
    (with pkgs; [caffeine-ng])
  ];
  services.flatpak.packages = ["org.kde.kclock" "org.kde.kcolorchooser"];
}
