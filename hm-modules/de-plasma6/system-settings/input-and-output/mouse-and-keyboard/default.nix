{...}: {
  imports = [./touchpad.nix ./mouse.nix];

  # to keep color appearance
  programs.plasma.resetFilesExclude = ["kcminputrc"];
}
