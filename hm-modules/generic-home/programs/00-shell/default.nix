{...}: {
  imports = [
    ./bash.nix
    ./zsh.nix
    ./fish.nix
    ./nushell.nix

    ./programs

    ./shell-aliases.nix
    ./session-variables.nix
  ];
}
