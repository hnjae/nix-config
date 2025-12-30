{
  flake.templates = {
    configurations = {
      path = ./configurations;
      description = "sample home/nixos configuration";
    };
    crane-flake-parts-example = {
      path = ./crane-flake-parts-example;
      description = "example project using `crane` and `flake-parts`";
    };
    devshell = {
      path = ./devshell;
      description = "development shell using `devshell` and `flake-parts`";
    };
    devshell-flake-parts = {
      path = ./devshell-flake-parts;
      description = "development shell using `pkgs.mkShell` and `flake-parts`";
    };
    devshell-minimal-deps = {
      path = ./devshell-minimal-deps;
      description = "development shell using `pkgs.mkShell`";
    };
    nix-shell = {
      path = ./nix-shell;
      description = "`nix-shell` templates";
    };
  };
}
