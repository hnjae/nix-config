{
  inputs,
  self,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
  flakeArgs = {
    localFlake = self;
    inherit flake-parts-lib;
    inherit importApply;
    inherit inputs;
  };
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
        module = importApply ./nixvim-module flakeArgs;
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
            vimdiff = pkgs.writeScript "vimdiff" ''
              #!${pkgs.dash}/bin/dash

              exec "${package}/bin/nvim" -d "$@"
            '';
          in
          pkgs.runCommandLocal "vim" { } ''
            mkdir -p "$out/bin"

            ln -s "${package}/bin/nvim" "$out/bin/vi"
            ln -s "${package}/bin/nvim" "$out/bin/vim"
            # ln -s "${package}/bin/nvim" "$out/bin/nvim"
            ln -s "${package}/bin/nvim" "$out/bin/nano"
            ln -s "${vimdiff}" "$out/bin/vimdiff"
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
