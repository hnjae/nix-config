{
  lib,
  config,
  ...
}:
let
  moduleName = "base-home";
  cfg = config.${moduleName};
in
{
  options.${moduleName} =
    let
      inherit (lib) mkOption types;
    in
    {
      isDesktop = mkOption {
        type = types.bool;
        default = false;
        description = "Is this a desktop system with GUI enabled?";
      };
      isDev = mkOption {
        type = types.bool;
        default = false;
        description = "Should I install development tools?";
      };
    };

  imports = [
    ./configs
    ./modules
    ./programs
    ./services
  ];
}
