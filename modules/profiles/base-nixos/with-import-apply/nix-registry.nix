{ inputs, localFlake, ... }:
{
  lib,
  config,
  ...
}:
{
  # for nix shell nixpkgs#foo
  # run `nix registry list` to list current registry
  nix.registry = {
    nixpkgs = {
      flake = inputs.nixpkgs-unstable;
      to = {
        path = "${inputs.nixpkgs-unstable}";
        type = "path";
      };
    };
    nixpkgs-stable = {
      flake = inputs.nixpkgs;
      to = {
        path = "${inputs.nixpkgs}";
        type = "path";
      };
    };
    nix-config = {
      flake = localFlake;
      to = {
        path = "${localFlake}";
        type = "path";
      };
    };
  };

  # to use nix-shell, run `nix repl :l <nixpkgs>`
  nix.channel.enable = true;
  nix.nixPath = lib.lists.optionals config.nix.channel.enable [
    "nixpkgs=${inputs.nixpkgs-unstable}"
    "nixpkgs-stable=${inputs.nixpkgs}"
    # "/nix/var/nix/profiles/per-user/root/channels"
  ];

}
