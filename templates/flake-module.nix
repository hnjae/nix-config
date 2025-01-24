{...}: {
  flake.templates = {
    home-configuration = {
      path = ./nixos-configuration;
      description = "sample home-configuration";
    };
    nixos-configuration = {
      path = ./nixos-configuration;
      description = "sample nixos-configuration";
    };
  };
}
