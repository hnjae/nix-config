{
  config,
  pkgs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  imports = [
    ./zathura
    ./typst.nix
    ./editors
    ./libreoffice.nix
    ./desktop-apps.nix
  ];

  home.packages = builtins.concatLists [
    (with pkgs; [texlive.combined.scheme-small])
    (with pkgsUnstable; [ocrmypdf img2pdf])
  ];
}
