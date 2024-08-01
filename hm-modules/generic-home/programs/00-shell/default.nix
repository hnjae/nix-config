{...}: {
  imports = [
    ./bash.nix
    ./zsh.nix
    ./fish.nix
    ./nushell.nix

    ./environment-variables
    ./aliases

    ./programs
  ];
}
