{...}: {
  imports = [
    ./bash.nix
    ./zsh
    ./fish.nix
    ./nushell.nix

    ./programs

    ./shell-aliases.nix
    ./session-variables.nix
  ];
}
