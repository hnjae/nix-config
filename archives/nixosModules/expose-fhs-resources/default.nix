# Create an FHS mount to support flatpak host icons(& cursors)/fonts
/*

**NOTE**: 이 모듈을 쓰면 impermanence 모듈을 사용하지 못함. <2024-01-23>

차라리 아래 코드를 쓰고 /nix/store 을 모든 flatpak 앱에게 공개하는게 더 편함.
```nix
  systemd.tmpfiles.rules = [
    "L /usr/share/icons - - - - /run/current-system/sw/share/icons"
    "L /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
  ];
```
*/
/*
Based on following code:

url: https://github.com/NixOS/nixpkgs/issues/119433#issuecomment-1326957279
Author: alaviss from GitHub

License: MIT
Copyright (c) 2003-2024 Eelco Dolstra and the Nixpkgs/NixOS contributors

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
{
  config,
  pkgs,
  lib,
  ...
}: let
  serviceName = "expose-fhs-resources";
  cfg = config.${serviceName};
in {
  options.${serviceName} = {
    enable = lib.mkEnableOption (lib.mDoc "");
  };

  config = lib.mkIf cfg.enable {
    # fix various font issue
    system.fsPackages = [pkgs.bindfs];
    fileSystems = let
      mkRoSymBind = path: {
        device = path;
        fsType = "fuse.bindfs";
        options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
      };
      aggregatedFonts = pkgs.buildEnv {
        name = "system-fonts";
        paths = config.fonts.packages;
        pathsToLink = ["/share/fonts"];
      };
    in {
      # "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
      "/usr/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";

      # wallpapres (does not work as intended)
      # "/usr/share/wallpapers" = mkRoSymBind (config.system.path + "/share/backgrounds");
      # "/usr/share/wallpapers" = mkRoSymBind (${pkgs.gnome.gnome-backgrounds} + "/share/backgrounds");
    };
  };
}
