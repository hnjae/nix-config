_: {
  flake.constants = {
    # my ssh public key
    homeSshPublic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJzpwZFnwPxTF4TU7IX5AI+Nwpu9VvjI4A9Jlh3P0pu";
    home = import ./home-encrypted.nix;
  };
}
