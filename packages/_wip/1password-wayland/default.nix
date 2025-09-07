{
  pkgs ? import <nixpkgs-stable> { },
}:
let
  lib = pkgs.lib;
in

pkgs._1password-gui.overrideAttrs (old: {
  preferLocalBuild = true;
  preFixup = ''
    makeShellWrapper $out/share/1password/1password $out/bin/1password \
      "''${gappsWrapperArgs[@]}" \
      --suffix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.udev ]} \
      --add-flags "\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}"
  '';
  # --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
})
