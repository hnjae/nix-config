{pkgs, ...}: {
  environment.plasma5.excludePackages =
    (with pkgs.libsForQt5; [
      # konsole # requires konsole for embedded terminal
      # plasma-workspace-wallpapers
      oxygen
      oxygen-sounds
      plasma-browser-integration
      kate

      elisa
      gwenview
      okular
    ])
    ++ (with pkgs; [
      hack-font
      dejavu_fonts
    ]);
}
