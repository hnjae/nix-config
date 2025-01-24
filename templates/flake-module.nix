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
    devshell-numtide = {
      path = ./devshell-numtide;
      description = "development shell using numtide/devshell and flake-parts";
    };
    nix-shell = {
      path = ./nix-shell;
      description = "`nix-shell` templates";
    };
  };
}
