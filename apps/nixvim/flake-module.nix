{ inputs, ... }:
let
  inherit (inputs) nixvim;
in
{
  perSystem =
    {
      pkgs,
      system,
      config,
      ...
    }:
    let
      nixvimLib = nixvim.lib.${system};
      nixvimModule = {
        inherit system; # or alternatively, set `pkgs`
        module = import ./config;
        # You can use `extraSpecialArgs` to pass additional arguments to your module files
        extraSpecialArgs = { };
      };
    in
    {
      checks = {
        nixvim = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
      };

      packages = {
        nixvim =
          let
            package = nixvim.legacyPackages.${system}.makeNixvimWithModule nixvimModule;
          in
          pkgs.runCommandLocal "vim" { } ''
            mkdir -p "$out/bin"
            ln -s "${package}/bin/nvim" "$out/bin/vi"
            ln -s "${package}/bin/nvim" "$out/bin/vim"
            ln -s "${package}/bin/nvim" "$out/bin/nano"
          '';
      };

      apps = {
        vi = {
          type = "app";
          program = "${config.packages.nixvim}/bin/vi";
        };
      };
    };
}
