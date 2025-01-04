{...}: {
  imports = [
    ./bash.nix
    ./zsh
    ./fish.nix
    ./nushell.nix

    ./programs

    ./shell-aliases
    ./session-variables.nix
  ];
}
