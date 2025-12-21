let
  project = "zfs-snapshot-prune";
in
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
        ${project} = import ./. { inherit pkgs; };
      };

      apps = lib.mkIf isSupported {
        ${project} = {
          type = "app";
          program = config.packages.zfs-snapshot-prune;
        };
      };
    };
}
