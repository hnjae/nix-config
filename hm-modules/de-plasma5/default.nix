{
  inputs,
  pkgs,
  config,
  # plasma-manager,
  ...
}:
# let
# kfiledialogSettings = {
#   "detailViewIconSize" = 16;
#   "iconViewIconSize" = 64;
#   "listViewIconSize" = 16;
# };
# in
{
  home.packages = [inputs.plasma-manager.packages.${pkgs.stdenv.system}.default];

  # NOTE: run `qdbus org.kde.KWin /KWin reconfigure` after homemanager switch <2023-03-29>
  imports = [
    ./hardware
    ./workspace
    ./appearance
    ./personalization
    ./apps
    ./packages
    ./xdg-autostart-fix
  ];

  programs.plasma.enable = true;

  # Misc
  programs.plasma.configFile."plasma_calendar_holiday_regions"."General"."selectedRegions".value = "kr_ko";
  programs.plasma.configFile."kwinrc"."ModifierOnlyShortcuts"."Meta".value = "";

  xdg.dataFile."color-schemes/base24.colors".source =
    config.scheme {templateRepo = inputs.base24-kdeplasma;};
}
