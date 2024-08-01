{
  self,
  inputs,
  pkgs,
  ...
}: {
  # options.plasma6 ={};

  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    #
    ./modules
    ./system-settings
    ./plasma-default-apps
    ./app-settings
    ./fcitx5
  ];

  config = {
    home.packages = [inputs.plasma-manager.packages.${pkgs.stdenv.system}.default];

    programs.plasma = {
      enable = true;
      overrideConfig = true;
      resetFilesExclude = [
        # kde 에 의해 계속 새로 생성되는 파일들
        # "systemsettingsrc"
        # "kded5rc"
      ];
    };

    # TODO: plasma-manager 에 아래가 있는지 확인하고 없으면 activation script
    # 에 넣는걸 고민해보기. <2024-06-11>
    # NOTE: run `qdbus org.kde.KWin /KWin reconfigure` after homemanager switch <2023-03-29>

    # Misc
    # programs.plasma.configFile."plasma_calendar_holiday_regions"."General"."selectedRegions".value = "kr_ko";
  };
}
