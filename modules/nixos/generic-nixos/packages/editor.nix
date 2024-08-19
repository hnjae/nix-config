{pkgs, ...}: {
  # disable nano
  programs.nano.enable = false;

  # Set of default packages that aren't strictly necessary for a running system
  environment.defaultPackages = with pkgs; [
    nixvim
  ];
}
