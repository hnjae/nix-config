/*
  <https://www.arewesixelyet.com/>
    NOTE: wayland-input-protocol 의 한계로 GTK, QT 를 안쓰는 터미널은 한글 입력시 잦은 애로 사항이 있음. <NixOS 23.11>

    NOTE:
      rio: terminal built with rust, no fontconfig, sixel support
      darktile: no wayland support <https://github.com/liamg/darktile/issues/313>
      contour: wayland 에서 폰트 렌더링이 이상함.

    NOTE: cosmic-term  <2024-11-11>
      * https://bbs.archlinux.org/viewtopic.php?id=294816
      * wl_drm#48: error 0: wl_drm.create_prime_buffer is not implemented
      * It seems plasma6 wayland session uses linux-dmabuf(wayland protocol), but AMDVLK/AMDGPU-PRO driver only support wl_drm
*/
{ ... }:
{
  imports = [
    ./alacritty
    ./ghostty
    ./warp-terminal
  ];
}
