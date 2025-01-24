{
  # run nix-develop
  # description = "PROJECT DESCRIPTION";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs = {
      type = "indirect";
      id = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      mkShellWrapper = (
        pkgs:
        pkgs.mkShell {
          env = {
            PYTHONPATH = "$PHTHONPATH:/usr/lib/python3.7/lib-dynload";
          };

          packages = with pkgs; [ hello ];

          shellHook = ''
            echo "blabla"
          '';
        }
      );
    in
    {
      devShells = nixpkgs.lib.genAttrs supportedSystems (system: {
        default = mkShellWrapper (import nixpkgs { inherit system; });
      });
    };
}
