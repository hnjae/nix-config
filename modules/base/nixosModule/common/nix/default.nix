{lib, ...}: {
  imports = [
    ./managing.nix
  ];

  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      experimental-features = ["nix-command" "flakes"];

      # make builders to use cache
      builders-use-substitutes = lib.mkOverride 999 true;

      auto-optimise-store = lib.mkOverride 999 false;
      keep-failed = lib.mkOverride 999 true;

      # use-xdg-base-directories = true;

      trusted-users = [
        "@wheel"
      ];
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
