{ ... }:
{
  flake.templates = {
    configurations = {
      path = ./configurations;
      description = "sample home/nixos configuration";
    };
  };
}
