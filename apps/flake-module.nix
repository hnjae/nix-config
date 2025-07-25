{
  perSystem =
    { pkgs, ... }:
    {
      # Utilized by `nix run .#<name>`
      apps = rec {
        rustic-zfs = {
          type = "app";
          program = (import ./rustic-zfs { inherit pkgs; });
        };
        default =
          let
            script = pkgs.writeShellScript "benchmark" ''
              echo "----"
              echo "luks benchmark"
              echo "----"
              ${luks-benchmark.program}

              echo ""
              echo "----"
              echo "btrfs benchmark"
              echo "----"
              ${btrfs-benchmark.program}
            '';
          in
          {
            type = "app";
            program = "${script}";
          };

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
              postBuild =
                (old.postBuild or "")
                + ''
                  make hash-speedtest
                '';
              postInstall =
                (old.postInstall or "")
                + ''
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
