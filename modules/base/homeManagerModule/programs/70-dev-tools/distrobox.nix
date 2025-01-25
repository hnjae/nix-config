{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    home.packages = [ pkgsUnstable.distrobox ];

    stateful.nodes = [
      {
        path = "${config.xdg.dataHome}/icons/distrobox";
        mode = "755";
        type = "dir";
      }
    ];
  };
}
