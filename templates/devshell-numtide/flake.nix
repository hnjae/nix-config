{
  # description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    devshell,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        devshell.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem = {pkgs, ...}: {
        # or use `devShells.default = pkgs.mkShell`
        devshells.default = {
          env = [
            {
              name = "HTTP_PORT";
              value = 8080;
            }
          ];
          commands = [
            {
              help = "print hello";
              name = "hello";
              command = "echo hello";
            }
          ];
          packages = [
            pkgs.cowsay
          ];
        };
      };
    };
}
