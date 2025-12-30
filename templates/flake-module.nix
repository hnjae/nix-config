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
    mkshell = {
      path = ./mkshell;
      description = "development shell using `pkgs.mkShell`";
    };
    mkshell-advanced = {
      path = ./mkshell;
      description = "development shell using `pkgs.mkShell` with `treefmt-nix`";
    };
    devshell = {
      path = ./devshell;
      description = "development shell using `devshell`, `treefmt-nix` and `flake-parts`";
    };
    nix-shell = {
      path = ./nix-shell;
      description = "`nix-shell` templates";
    };
  };
}
