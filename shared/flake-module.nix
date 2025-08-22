{
  flake.shared = {
    keys.ssh = {
      # my public ssh key
      home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJzpwZFnwPxTF4TU7IX5AI+Nwpu9VvjI4A9Jlh3P0pu";
      nix-ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzt3w6yY1EwRrMs2m2rdGtgnp/+51n+9grZw66CyhA1";
    };

    # home = import ./home-encrypted.nix;
    hosts = import ./hosts-encrypted.nix;

    lib = {
      rusticIgnoreFileFactory = import ./lib/rustic-ignorefile-factory.nix;
    };
  };
}
