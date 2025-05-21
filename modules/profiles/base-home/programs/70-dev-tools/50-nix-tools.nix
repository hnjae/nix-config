{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
  aliases = {
    se = "sops edit";
  };
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    # locate the package providing a certain files in `nixpkgs`
    # use hm's module for shell integration
    programs.nix-index = {
      enable = true;
    };

    home.packages = with pkgsUnstable; [
      sops # edit secrets

      # make shell.nix, flake.nix based on nix-shell
      shellify

      # create nix fetche calls from repository URLs
      nurl

      # auto-generate nix stderivation
      nix-init

      # run nixpkgs' pkg with , (comma) (use nix-index-database's)
      # comma

      # docker-compose to nix
      compose2nix

      # deploy-rs
      deploy-rs
    ];

    home.shellAliases = aliases;

    xdg.configFile."zsh-abbr/user-abbreviations".text = (
      lib.concatLines (lib.mapAttrsToList (key: value: ''abbr "${key}"="${value}"'') aliases)
    );
  };
}
