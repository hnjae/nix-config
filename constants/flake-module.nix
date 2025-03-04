_: {
  flake.constants = {
    # my ssh public key
    homeSshPublic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJzpwZFnwPxTF4TU7IX5AI+Nwpu9VvjI4A9Jlh3P0pu";
    nixSshPublic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzt3w6yY1EwRrMs2m2rdGtgnp/+51n+9grZw66CyhA1";

    home = import ./home-encrypted.nix;
    hosts = import ./hosts-encrypted.nix;

    configs = import ./configs.nix;
  };
}
