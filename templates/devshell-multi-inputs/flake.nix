{
  # description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs = {
    #   type = "indirect";
    #   id = "nixpkgs-unstable";
    # };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = builtins.concatLists [
        (lib.lists.optional (inputs.devshell ? flakeModule) inputs.devshell.flakeModule)
        (lib.lists.optional (inputs.treefmt-nix ? flakeModule) inputs.treefmt-nix.flakeModule)
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        { pkgs, ... }:
        {
          # Utilized by `nix develop`
          devshells.default = lib.mkIf (inputs.devshell ? flakeModule) {
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

          # Utilized by `nix fmt`
          treefmt.config = lib.mkIf (inputs.treefmt-nix ? flakeModule) {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
              just.enable = true;
              mdformat.enable = true;
              taplo.enable = true;
              yamlfmt.enable = true;
              ruff-format.enable = true;
            };
            settings = {
              global.excludes = [
                ".editorconfig"
                "LICENSE"
              ];
            };
          };
        };
    };
}
