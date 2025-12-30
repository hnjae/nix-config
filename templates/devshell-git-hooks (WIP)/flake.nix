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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
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
        (lib.lists.optional (inputs.treefmt-nix ? flakeModule) inputs.treefmt-nix.flakeModule)
        (lib.lists.optional (inputs.git-hooks ? flakeModule) inputs.git-hooks.flakeModule)
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          pkgs,
          config,
          self',
          ...
        }:
        {
          # Utilized by `nix develop`
          devShells.default = pkgs.mkShellNoCC {
            env = {
              FOO = "bar";
            };

            packages = with pkgs; [ hello ];

            shellHook = ''
              ${config.pre-commit.installationScript}
              echo "blabla"
            '';
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

          # Utilized by `nix flake check`
          pre-commit = lib.mkIf (inputs.git-hooks ? flakeModule) {
            settings = {
              hooks = {
                treefmt = {
                  enable = true;
                  # packageOverrides.treefmt = self'.formatter;
                  settings.formatters = with pkgs; [
                    nixfmt-rfc-style
                  ];
                };
              };
            };
          };
        };
    };
}
