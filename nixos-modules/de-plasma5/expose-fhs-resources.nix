{
  self,
  config,
  lib,
  ...
}: let
  inherit (config.generic-nixos) isDesktop;
in
  lib.attrsets.optionalAttrs isDesktop {
    imports = [
      self.nixosModules.expose-fhs-resources
    ];
    expose-fhs-resources.enable = true;
  }
