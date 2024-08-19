_: {
  imports = [
    ./managing.nix
    ./registry.nix
  ];

  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      experimental-features = ["nix-command" "flakes"];

      # make builders to use cache
      builders-use-substitutes = true;

      auto-optimise-store = false;
      keep-failed = true;

      # use-xdg-base-directories = true;
    };

    # HELP: run `man 5 nix.conf`
    extraOptions = let
      fromGiBtoB = num: toString (num * 1024 * 1024 * 1024);
    in ''
      # keep-env-derivations = true
      min-free = ${fromGiBtoB 16}
      max-free = ${fromGiBtoB 128}
    '';
  };
}
