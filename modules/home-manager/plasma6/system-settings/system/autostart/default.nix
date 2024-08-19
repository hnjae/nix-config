{...}: {
  imports = [
    # ./fcitx.nix
    ./1password.nix
    ./caffeine
  ];

  # NOTE:
  # https://docs.kde.org/stable5/en/plasma-workspace/kcontrol/autostart/autostart.pdf
  # https://userbase.kde.org/Session_Environment_Variables
}
