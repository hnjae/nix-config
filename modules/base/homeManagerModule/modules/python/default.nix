{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.python;
in {
  options.python = {
    enable = lib.mkEnableOption (lib.mdDoc "Python");

    # NOTE:
    # https://www.python.org/downloads/ 에서 새 버전 나왔다고 바로 업그레이드 하지 말고
    # https://archlinux.org/packages/core/x86_64/python 가 버전업 할 경우 따라가자
    # <2024-02-01>
    package = mkOption {
      type = types.package;
      default = pkgs.python312;
    };

    pythonPackages = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (cfg.package.withPackages (python-pkgs: (builtins.map (x: (builtins.getAttr x python-pkgs))
          cfg.pythonPackages)))
    ];
  };
}
