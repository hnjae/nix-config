{ inputs, localFlake, ... }:
{ lib, config, ... }:
let
  isDesktop = config.base-nixos.role == "desktop";
  fromGiBtoB = num: toString (num * 1024 * 1024 * 1024);

  flakes =
    lib.filterAttrs
      (name: input: ((!lib.hasPrefix "z_" name) && (input ? _type) && input._type == "flake"))
      (
        # merge localFlake
        inputs // { nix-config = localFlake; }
      );
in
{
  nix = {
    # man:systemd.exec(5)
    daemonCPUSchedPolicy = lib.mkOverride 999 (if isDesktop then "batch" else "idle"); # default: other (NixOS 25.11)
    daemonIOSchedClass = lib.mkOverride 999 "best-effort"; # default: best-effort (NixOS 25.11)
    daemonIOSchedPriority = lib.mkOverride 999 7; # default: 4  (NixOS 25.11)

    # HELP: run `man 5 nix.conf`
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      cores = lib.mkOverride 999 0; # use all available CPU cores
      max-jobs = lib.mkOverride 999 (if isDesktop then 2 else 1); # max concurrent build; default: "auto" <NixOS 25.11>;

      # make builders to use cache
      builders-use-substitutes = lib.mkOverride 999 true;
      auto-optimise-store = lib.mkOverride 999 false;
      keep-failed = lib.mkOverride 999 true;

      trusted-users = [ "@wheel" ];

      min-free = lib.mkOverride 999 "${fromGiBtoB 4}";
    };

    /*
      - man:nix3-registry(1)
      - used in `nix shell nixpkgs#foo`
      - run `nix registry list` to list current registry

      ※ `system` registry로 등록됨. stateful 한 registry 는 `global` 혹은 `user 로 등록됨.
    */
    registry = lib.mkOverride 51 (
      builtins.mapAttrs (_: input: {
        to = {
          path = "${input}";
          type = "path";
        };
      }) flakes
    );

    /*
      configuration of "$NIX_PATH":
      default (NixOS 25.11):
        - "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
            - 여기서 `/nixos` 가 nixpkgs의 git-root 임.
        - "nixos-config=/etc/nixos/configuration.nix"
        - "/nix/var/nix/profiles/per-user/root/channels"
    */
    nixPath = lib.mkOverride 51 (lib.mapAttrsToList (name: _: "${name}=flake:${name}") flakes);

    # nix-channel --list
    channel.enable = lib.mkOverride 51 false; # nix-channel 은 stateful 하게 관리되니 기피.
  };

  # 위에서 수동으로 설정하였음.
  nixpkgs.flake.setNixPath = lib.mkOverride 999 false;
  nixpkgs.flake.setFlakeRegistry = lib.mkOverride 999 false;

  # Whether to use ‘nixos-rebuild-ng’ in place of ‘nixos-rebuild’, the Python-based re-implementation of the original in Bash.
  system.rebuild.enableNg = true;
}
