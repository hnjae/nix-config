{ inputs, ... }:
{
  lib,
  config,
  ...
}:
{
  # for nix shell nixpkgs#foo
  # run `nix registry list` to list current registry
  nix.registry = {
    nixpkgs-unstable = {
      flake = inputs.nixpkgs-unstable;
      to = {
        path = "${inputs.nixpkgs-unstable}";
        type = "path";
      };
    };
    nixpkgs = {
      flake = inputs.nixpkgs;
      to = {
        path = "${inputs.nixpkgs}";
        type = "path";
      };
    };
  };

  # to use nix-shell, run `nix repl :l <nixpkgs>`
  nix.channel.enable = true;
  nix.nixPath = lib.lists.optionals config.nix.channel.enable [
    "nixpkgs=${inputs.nixpkgs}"
    "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    # "/nix/var/nix/profiles/per-user/root/channels"
  ];

}
