{...}: {
  # README: 말도 안되게 작아지는 앱들 한정해서 설정할 것.
  imports = [
    ./picture-in-picture.nix
    ./password-promt.nix
    ./minsize.nix
    ./minsize-thunderbird.nix
    ./force-border.nix

    ./show-in-all-activities.nix
    ./show-in-all-activities-and-desktop.nix

    ./above-all-other-windows.nix

    ./chromium.nix
  ];
}
