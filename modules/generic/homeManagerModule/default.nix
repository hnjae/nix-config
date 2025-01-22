{
  lib,
  config,
  pkgs,
  ...
}: let
  moduleName = "generic-home";
  cfg = config.${moduleName};
in {
  options.${moduleName} = let
    inherit (lib) mkOption types;
  in {
    isDesktop = mkOption {
      type = types.bool;
      default = false;
    };
    terminalFontSize = mkOption {
      type = types.int;
      default = 11;
    };
    installDevPackages = mkOption {
      type = types.bool;
      default = false;
    };
    installTestApps = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        내가 실제로 자주 사용하는 프로그램이 아닌, 단순히 호기심이나 시험 삼아
        설치해보는 프로그램들의 설치 여부를 결정.
      '';
    };
  };

  imports = [
    ./modules
    ./services
    ./programs
    ./options
  ];
}
