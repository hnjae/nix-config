{
  perSystem =
    {
      pkgs,
      lib,
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
      apps = lib.mkIf isSupported {
        # Utilized by `nix run .#<name>`
        btrfs-benchmark =
          let
            # based on https://gist.github.com/schlarpc/20bca64eb7cd76733c459941df5759f8
            btrfs-procs = pkgs.btrfs-progs.overrideAttrs (old: {
              postBuild = (old.postBuild or "") + ''
                make hash-speedtest
              '';
              postInstall = (old.postInstall or "") + ''
                cp hash-speedtest $out/bin
              '';
            });
          in
          {
            type = "app";
            program = "${btrfs-procs}/bin/hash-speedtest";
          };

        luks-benchmark = {
          type = "app";
          program = pkgs.writeScriptBin "luks-benchmark" ''
            #!${pkgs.dash}/bin/dash

            set -eu

            exec ${pkgs.cryptsetup}/bin/cryptsetup benchmark
          '';
        };
      };
    };
}
