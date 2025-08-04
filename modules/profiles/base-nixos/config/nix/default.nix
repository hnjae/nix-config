{ lib, ... }:
let
  fromGiBtoB = num: toString (num * 1024 * 1024 * 1024);
in
{
  imports = [
    ./managing.nix
  ];

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
      min-free = lib.mkOverride 999 "${fromGiBtoB 16}";
    };
  };

  # Whether to use ‘nixos-rebuild-ng’ in place of ‘nixos-rebuild’, the Python-based re-implementation of the original in Bash.
  system.rebuild.enableNg = true;
}
