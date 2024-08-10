{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    # locate the package providing a certain files in `nixpkgs`
    # use hm's module for shell integration
    programs.nix-index = {
      enable = true;
    };

    home.packages = with pkgsUnstable; [
      # make shell.nix, flake.nix based on nix-shell
      shellify

      # create nix fetche calls from repository URLs
      nurl

      # auto-generate nix stderivation
      nix-init

      # run nixpkgs' pkg with , (comma)
      comma
    ];
  };
}
