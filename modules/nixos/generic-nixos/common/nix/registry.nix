{
  inputs,
  lib,
  config,
  ...
}: {
  nix = {
    # for nix shell nixpkgs#blabla
    # run `nix registry list` to list current registry
    registry = {
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
    };

    # to use nix-shell, run `nix repl :l <nixpkgs>`
    channel.enable = true;
    nixPath = lib.lists.optionals config.nix.channel.enable [
      "nixpkgs=${inputs.nixpkgs-unstable}"
      "nixpkgs-stable=${inputs.nixpkgs}"
      # "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };
}
