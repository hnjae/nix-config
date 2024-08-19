{
  config,
  lib,
  ...
}: {
  # environment.systemPackages = [ pkgs.man-pages pkgs.man-pages-posix ];
  documentation.dev.enable = lib.mkOverride 999 (config.generic-nixos.role == "desktop");
}
