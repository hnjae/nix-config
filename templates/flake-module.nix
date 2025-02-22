{ ... }:
{
  flake.templates = {
    configurations = {
      path = ./configurations;
      description = "sample home/nixos configuration";
    };
    devshell = {
      path = ./devshell;
      description = "development shell";
    };
    devshell-multi-inputs = {
      path = ./devshell-multi-inputs;
      description = "development shell using `devshell`, `treefmt-nix` and `flake-parts`";
    };
    nix-shell = {
      path = ./nix-shell;
      description = "`nix-shell` templates";
    };
  };
}
