{
  imports = [
    ./nixvim/flake-module.nix
    ./rustic-zfs/flake-module.nix
  ];

  perSystem =
    { pkgs, ... }:
    {
      # Utilized by `nix run .#<name>`
      apps = {
        luks-benchmark = {
          type = "app";
          program = pkgs.writeShellScript "luks-benchmark" ''
            ${pkgs.cryptsetup}/bin/cryptsetup benchmark
          '';
        };

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
      };
    };
}
