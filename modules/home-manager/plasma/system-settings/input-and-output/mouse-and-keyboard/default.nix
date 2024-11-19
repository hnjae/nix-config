{...}: {
  imports = [./touchpad.nix ./mouse.nix];

  # keep changes
  programs.plasma.resetFilesExclude = ["kcminputrc"];
}
