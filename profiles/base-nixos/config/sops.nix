{
  sops = {
    gnupg.sshKeyPaths = [ ];
    age = {
      keyFile = "/secrets/home-age-private";
      sshKeyPaths = [ ];
      generateKey = false;
    };
  };
}
