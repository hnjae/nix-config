{
  perSystem =
    {
      pkgs,
      lib,
      config,
      system,
      ...
    }:

    let
      isSupported = builtins.elem system [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      packages = lib.mkIf isSupported {
        zfs-snapshot-prune = import ./. { inherit pkgs; };
      };
      apps = lib.mkIf isSupported {
        zfs-snapshot-prune = {
          type = "app";
          program = config.packages.zfs-snapshot-prune;
        };
      };
    };
}
