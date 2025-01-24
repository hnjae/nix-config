{ ... }:
{
  home.preferXdgDirectories = true;
  # https://github.com/nix-community/home-manager/blob/master/modules/home-environment.nix#L528

  # nix = {
  #   enable = true;
  #   package = pkgs.nix;
  #   settings = {
  #     use-xdg-base-directories = true;
  #   };
  # };
}
