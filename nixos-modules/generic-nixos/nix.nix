{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (config.generic-nixos) isDesktop;
in {
  nix.daemonCPUSchedPolicy =
    if isDesktop
    then "idle"
    else "batch";
  nix.daemonIOSchedClass =
    if isDesktop
    then "idle"
    else "best-effort";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];

    # make builders to use cache
    builders-use-substitutes = true;

    auto-optimise-store = false;
    keep-failed = true;

    # use-xdg-base-directories = true;
  };

  # for nix shell nixpkgs#blabla
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
  };

  # to use nix-shell, run `nix repl :l <nixpkgs>`
  nix.channel.enable = true;
  nix.nixPath = lib.lists.optionals config.nix.channel.enable [
    "nixpkgs=${inputs.nixpkgs-unstable}"
    "nixpkgs-stable=${inputs.nixpkgs}"
    # "/nix/var/nix/profiles/per-user/root/channels"
  ];

  # HELP: run `man 5 nix.conf`
  nix.extraOptions = let
    fromGiBtoB = num: toString (num * 1024 * 1024 * 1024);
  in ''
    keep-env-derivations = true
    min-free = ${fromGiBtoB 64}
    max-free = ${fromGiBtoB 128}
  '';
}
