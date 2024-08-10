{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      # make shell.nix, flake.nix based on nix-shell
      shellify
      # run nixpkgs' pkg with , (comma)
      comma
      # auto-generate nix stderivation
      nix-init
      # locate the package providing a certain files in `nixpkgs`
      nix-index
      # create nix fetche calls from repository URLs
      nurl
    ];
  };
}
