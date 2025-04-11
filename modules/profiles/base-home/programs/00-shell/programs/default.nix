# NOTE: enableBashIntegration 같은 것이 있는 옵션들 <2024-02-13>
{ ... }:
{
  imports = [
    ./any-nix-shell.nix
    ./chpwd.nix
    ./dircolors.nix
    ./direnv.nix
    ./greeting.nix
    ./man.nix
    ./mc.nix
    ./starship.nix
    ./zoxide.nix
  ];
}
