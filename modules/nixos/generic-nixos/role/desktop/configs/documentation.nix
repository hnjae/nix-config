{lib, ...}: {
  # environment.systemPackages = [ pkgs.man-pages pkgs.man-pages-posix ];
  documentation.dev.enable = lib.mkOverride 999 true;
}
