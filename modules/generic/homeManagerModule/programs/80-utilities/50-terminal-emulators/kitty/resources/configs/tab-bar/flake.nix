{
  description = "devshell";
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = {nixpkgs, ...}: let
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
    mapShell = lambda:
      builtins.listToAttrs (builtins.map (system: {
          name = system;
          value = {default = lambda (import nixpkgs {inherit system;});};
        })
        supportedSystems);
  in {
    devShells = mapShell (pkgs: (pkgs.mkShell {
      # env = {
      #   PYTHONPATH = "${pkgs.kitty}/lib/kitty";
      # };

      packages = with pkgs; [
        kitty

        # pylyzer
        ruff

        (python3.withPackages
          (ps: with ps; [black isort ruff-lsp python-lsp-server]))
      ];
    }));
  };
}
