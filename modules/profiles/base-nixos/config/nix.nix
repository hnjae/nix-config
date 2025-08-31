{ inputs, localFlake, ... }:
{ lib, config, ... }:
let
  fromGiBtoB = num: toString (num * 1024 * 1024 * 1024);
in
{
  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # make builders to use cache
      builders-use-substitutes = lib.mkOverride 999 true;

      auto-optimise-store = lib.mkOverride 999 false;
      keep-failed = lib.mkOverride 999 true;

      # use-xdg-base-directories = true;

      trusted-users = [
        "@wheel"
      ];

      # HELP: run `man 5 nix.conf`
      min-free = lib.mkOverride 999 "${fromGiBtoB 4}";
    };

    # for nix shell nixpkgs#foo
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
      nix-config = {
        flake = localFlake;
        to = {
          path = "${localFlake}";
          type = "path";
        };
      };
    };

    # to use nix-shell, run `nix repl :l <nixpkgs>`
    channel.enable = true;
    nixPath = lib.lists.optionals config.nix.channel.enable [
      # "/nix/var/nix/profiles/per-user/root/channels"
      "nixpkgs=${inputs.nixpkgs-unstable}"
      "nixpkgs-stable=${inputs.nixpkgs}"
      "nix-config=${localFlake}"
    ];
  };

  # Whether to use ‘nixos-rebuild-ng’ in place of ‘nixos-rebuild’, the Python-based re-implementation of the original in Bash.
  system.rebuild.enableNg = true;
}
